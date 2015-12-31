#    Copyright (C) 2015 Taylor Raack
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License along
#    with this program; if not, write to the Free Software Foundation, Inc.,
#    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

echo Trying to find python version...

python_version=`python -c 'import sys; print(".".join(map(str, sys.version_info[:3])))'`

case "$python_version" in
  "3.4"*)
    system_python=python3.4
    headers_version=3.4.4
    ;;
  "3.3"*)
    system_python=python3.3
    headers_version=3.3.6
    ;;
  "3.2"*)
    system_python=python3.2
    headers_version=3.2.6
    ;;
  *)
    echo Python version was not understood. It was detected as - $python_version
    ;;
esac

sudo apt-get update
sudo apt-get install libdbus-glib-1-2

pkg-config --exists --print-errors "dbus-glib-1 >= 0.200"

# need dbus 1.6 or greater to compile python-dbus
echo Downloading dbus...
wget http://dbus.freedesktop.org/releases/dbus/dbus-1.6.30.tar.gz -O dbus.tar.gz -q
echo Unpacking dbus...
tar -zxvf dbus.tar.gz > /dev/null
rm dbus.tar.gz

cd dbus-1.6.30

./configure
make
sudo make install

cd ..

echo Downloading python-$headers_version
wget https://www.python.org/ftp/python/$headers_version/Python-$headers_version.tgz -O python.tar.gz -q
echo Unpacking python...
tar -zxvf python.tar.gz > /dev/null
rm python.tar.gz
echo Configuring Python to get all headers...
cd Python-*
python_src_dir=`pwd`
./configure

echo Downloading python-dbus...
wget http://dbus.freedesktop.org/releases/dbus-python/dbus-python-1.2.0.tar.gz -O dbus-python.tar.gz -q
echo Unpacking python-dbus...
tar -zxvf dbus-python.tar.gz > /dev/null
rm dbus-python.tar.gz

mkdir -p python-tmpenv

python_virtualenv=$VIRTUAL_ENV
python_tmpenv=`pwd`/python-tmpenv

cd dbus-python-1.2.0

PYTHON=`sudo which ${system_python}` ./configure PYTHON_INCLUDES="-I$python_src_dir/Include -I$python_src_dir" --prefix=$python_tmpenv
make
make install

cd ..

echo Copying files from the temporary python env to the virtualenv
cp -r $python_tmpenv/* $python_virtualenv