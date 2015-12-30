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