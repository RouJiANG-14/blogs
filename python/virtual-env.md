# Python virtual env
最近在用ops写的一个脚本，需要用到python 3，以及部分安装依赖，于是顺利的安装了python 3的环境，但是一切并没有那么的顺利，依赖的一个包死活无法安装，于是了解到了python的[虚拟环境](https://docs.python.org/3/tutorial/venv.html).

## 使用
```shell
python3 -m venv v-env
```
命令行输出
```
➜  python-virtual-env ls
➜  python-virtual-env touch test.py
➜  python-virtual-env ls
test.py
➜  python-virtual-env python3 -m venv v-env
➜  python-virtual-env ls
test.py v-env
```
可以看到文件中多了一个v-env的文件夹，里边内容如下：
```
➜  python-virtual-env cd v-env
➜  v-env tree -L 2
.
├── bin
│   ├── activate
│   ├── activate.csh
│   ├── activate.fish
│   ├── easy_install
│   ├── easy_install-3.7
│   ├── pip
│   ├── pip3
│   ├── pip3.7
│   ├── python -> python3
│   └── python3 -> /usr/local/bin/python3
├── include
├── lib
│   └── python3.7
└── pyvenv.cfg
```
加载到当前的shell窗口中
```
source v-env/bin/activate
```
```
(v-env) ➜  python-virtual-env ls
test.py v-env
(v-env) ➜  python-virtual-env python
Python 3.7.4 (default, Sep  7 2019, 18:27:02)
[Clang 10.0.1 (clang-1001.0.46.4)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> exit()
(v-env) ➜  python-virtual-env
```
之后你的目录中会出现`(v-env)`，这样代表你的虚拟环境加载成功了。
之后就可以最新所欲的玩了。

