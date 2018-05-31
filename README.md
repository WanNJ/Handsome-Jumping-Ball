# Handsome-Jumping-Ball

A jumping game animated in processing and intended to be integrated with Arduino board to bring interactions into real life.

此游戏将Processing作为前台，Arduino作为后台处理器，尽可能地还原了微信跳一跳，并加入了体感元素，但积分功能（前台）还有待添加。

## 主要设计思想

1. 通过一个IMU作为传感器，得到用户手腕摆动加速度，经过IMU-6500自带的DMP滤波算法处理后作为输入传入自定义的`getVel()`函数，以得到游戏里小球相应的初始速度（X方向）。

2. 在此实现中，由于IMU是通过连线的方式与Arduino交互的，大范围的移动显得不切实际。因此`getVel()`函数选择将用户手腕抖动过程中的最大加速度映射到相应的小球初速度上。但是如果IMU可以通过无线的形式和Arduino交流，更丰富的体感交互形式也就成为了可能，此时可以通过重新定义`getVel()`函数进行对游戏规则的修改。例如，使用"Dead Reckoning"来测量用户跳跃的幅度，实现真正意义上的“跳一跳”。

