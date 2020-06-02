# auto generate
最近准备让博客在GitHub上页有一份备份，用的是GitHub page，然后发现了一个小问题就是GitHub page默认是readme，也就是readme是默认入口，你的其他文件都只能在readme中放链接。

导致一个问题：
> 每次写完博客之后要在readme中进行更新，否则readme就看不到

于是写了一个[自动化脚本](https://github.com/1483523635/blogs/blob/master/generate.sh)
> 扫描当前repo然后自动生成markdown类型的readme
脚本写好了。

怎么用呢
* git pre-push hook
* github action 自动调用脚本，然后将更新的readme文件commit到github上
走的是第二条路
自动化脚本有兴趣的同学可以去看一下https://github.com/1483523635/blogs/blob/master/generate.sh
之后就是github Action
详细的action文件：https://github.com/1483523635/blogs/blob/master/.github/workflows/auto_generate_folder.yml
有两个action
```
    #  自动生成 readme 文件
    - name: GENERATE_README
      run: bash ./generate.sh

    # commit readme 文件
    - name: Commit changes
      uses: EndBug/add-and-commit@v4
      with:
        author_name: GITHUB_GENERATOR
        author_email: 1483523635@qq.com
        message: "AUTO GENERATE README"
        add: "*.md"
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```



一切都自动化了真好。