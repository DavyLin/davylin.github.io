---
layout: post
title: "CountDownLatch"
date: 2014-05-10 15:29:21 +0800
comments: true
tags: java,concurrence
categories: java
---

###同步工具类之闭锁-CountDownLatch

*闭锁*是一种同步工具类，可以延迟线程的进度直到其到达终止状态。闭锁的作用相当于一扇门：在闭锁到达结束状态之前，这扇门一直是关闭的，并且没有
任何线程能通过，当到达结束状态时，这扇门会打开并允许所有的线程通过。当闭锁到达结束状态后，将不会再改变状态，因此这扇门将永远保持打开状态。
闭锁可以用来确保某些活动直到其他活动都完成后才继续执行。
 
**`CountDownLatch`**是一种灵活的闭锁实现，可以在上述各种情况中使用，它可以使一个或多个线程等待一组事件发生。闭锁状态包括一个计数器，该计数器
被初始化为一个正数，表示需要等待的事件数量。`countDown`方法递减计数器，表示有一个事件已经发生了，而await方法等待计数器达到零，这表示所有
需要等待的事件都已经发生。如果计数器的值非零，那么`await`会一直阻塞直到计数器为零，或者等待中的线程中断，或者等待超时。

    public class TestHarness {  
    	public long timeTasks(int nthreads, final Runnable task) throws InterruptedException {  
        	final CountDownLatch startGate = new CountDownLatch(1);  
        	final CountDownLatch endGate = new CountDownLatch(nthreads);  
  
        	for (int i = 0; i < nthreads; i++) {  
            Thread t = new Thread(){  
                @Override  
                public void run() {  
                    try{  
                        startGate.await();  
                        try{  
                            task.run();  
                        }finally {  
                            endGate.countDown();  
                        }  
                    } catch (InterruptedException ignored) {}  
                }  
            };  
            t.start();  
        	}  
  
        	long start = System.nanoTime();  
        	startGate.countDown();  
        	endGate.await();  
        	long end = System.nanoTime();  
        	return end-start;  
    	}  
	}  

 
`startGate`计数器的初始值为1，而`endGate`计数器的初始值为工作线程的数量。每个工作线程首先要做的就是在startGate上等待，从而确保所有线程都就绪后
才开始执行。而每个线程要做的最后一件事情是将调用`endGate`的`countDown`方法减1，这能使主线程高效地等待直到所有工作线程都执行完成，因此可以更准确
地统计所消耗的时间
 
**ps. 为什么要在上例中使用闭锁，而不是在线程创建后就立即启动？或许，我们希望测试n个线程并发执行某个任务时需要的时间。如果在创建线程后立即启动
它们，那么先启动的线程将“领先”后启动的线程，并且活跃线程数量会随着时间的推移而增加或减少，竞争程度也在不断发生变化。**


