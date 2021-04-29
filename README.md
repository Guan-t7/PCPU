# 2020-2021秋冬 浙江大学 计算机体系结构 课程实验

本仓库为系列实验最后所设计出的 MIPS 流水线 CPU. 包含cache，不包含中断. 
兼容课程所提供的模板工程(VGA debugger).

最初的动机与 zh 类似，但由于比较菜，因此只抓主要矛盾： 

设计一个组织更加合理、更加符合理论课原理图(zju-icicles 体系目录下 schematic.png) 的 PCPU 模块，替换掉模板工程的 mips_core 模块。同时保证接口一致，减少实验验收的麻烦。

该 PCPU 在 SWORD V4 (325T) 上经过了部署和测试。

整体思路感谢 https://github.com/zhanghai/archexp 

- 使用 Python 脚本自动生成 流水线寄存器模块 和 顶层 PCPU 模块 的代码
- PPT 看得令人头疼，于是根据最终目标重新自己推导，力求思路清晰、优雅
