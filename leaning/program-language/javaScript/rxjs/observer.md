# Rxjs 修改Observable 里的值
> 有这么一个对象`c$: Observable<any>` 修改里边的值：
1.   声明一个subject `subject: Subject<any>;`
2. 在`ngOnInit() `中进行初始化 `    this.subject = new BehaviorSubject<object>(CLOSE_OPTIONS);`
 然后将`subject`赋值给`Observable`对象 `this.c$ = this.subject.asObservable();`
3. 更新值的地方这么写：`this.subject.next(CLOSE_CASE_OPTIONS);`

这样就做到只用一个Observable对象，来更新里边的值了
如果这么写`this.c$ = Observable.of(CLOSE_OPTIONS)` 这样做的话每次就会替换掉原来指向的那个对象。

## 更新
 最近发现 subject本身就是observable的，于是能够省掉一个Observable的对象了。`c$`