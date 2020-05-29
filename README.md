# AlertManager

## 为什么不使用 dismiss complete 的方法

因为系统的 UIAlertController 点击 action 后，无法接收到对应 dismiss 的通知

## 可不可以使用 KVO 监听 presentedViewController 和 beingDismiss 的方法来观察

不可以，系统的大部分只读属性是无法进行 KVO 的（也有能够 KVO 的），因为 KVO 的底层是通过实现 set 方法实现的
