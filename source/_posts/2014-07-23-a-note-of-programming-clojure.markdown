---
layout: post
title: "A Note of Programming Clojure"
date: 2014-07-23 11:02:19 +0800
comments: true
tags: clojure
categories: clojure
---
1.use 用来导入clojure.core命名空间

	user>(clojure.core/use 'clojure.core)

2.import导入java类

	user>(import '(java.io InputStream File))
	java.io.File

3.require引入clj到当前命名空间

	user>(require 'clojure.string)
	nil

4.查看信息

	user>(find-doc "ns-")
	
5.解构
	
	user>(let [[x y] [1 2 3]] 
				[x y])
	[1 2]
	user> (greet-author-2 [fname {:first-name}]
                (println "hello, " fname))
	; Evaluation aborted.
	user> (let [[_ _ z] [1 2 3]]
        z)
	3
	user> (let [[_ _ z] [1 2 3]]
        _)
	2
	user> (require '[clojure.string :as str])
	nil
	user> (let [[x y :as coords] [1 2 3 4 5 6]]
        	(str "x: " x ", y: " y ", total dimensions " (count 				coords)))
	"x: 1, y: 2, total dimensions 6"
	
6.常用数据类型
	
	Keyword   :tag, :doc
	List     (1 2 3), (pringln "foo")
	Map  {:name "bill", :age 42}
	Set  #{:snap  :crackle  :pop}
	Symbol    user/foo,
              java.lang.String
	Vector   [1 2 3]