# FootbalApp
Create a smoothy app for football matches

- MVVM and Clean architecture support
- Support offline mode first load and sync local and remote data for lastest data
- Suport cache for loading
- Support diffable datasource
- Follow coding standard and convention
- Support UI test
- Support Unit test
- Code coverage (configuration in Xcode 14 and 15 have some difference with Xcode 13)
- Support team filter

# Challenging technical issue when I faced:
I Particulary technical issues: 
In iOS project, I have worked with webRTC technical, this framework use for streaming between client and server, the issue in this iOS project is screen sharing quality is low. I must spend time to improve quality of screen sharing. To solve it, I do these step:

1. Understand correctly about issue, Should know this issue come by client or server, what is line of code the issue happen, what situation make this issue happen, how steps by steps to reproduce it => I must debug and research to understand about it

2. List all factor can make this issue happen, can make video low quality, this approach like brute force, to make sure I don't miss anything relative with this issue, what can make video resolution low.

3. After 1 and 2, we can limit the num of cause for issue, it make find the root cause more quickly, if I can not find the root cause then I use log service to log all of infor relative in some of these possible cause, log in all server and client.

4. From 3, I know the root cause, the rootcase is server and client are streaming low resolution in log info: just 378x540. eventhough client just send resolution 1024x1080 => this root cause come from WebRTC

5. Then I try to solve it with available technical, I must break down the code into smallest code to find the configuration that make sure don't have missing configuration or wrong configuration for WebRTC in code of project.

6. After break it down, I still can not find any missing/wrong configuration. So I must research more about WebRTC to understand indeep inside this framework, and then after deep dive to this framework, I know the root cause is webRTC use h264 algorithm for decode and encode buffer, it must have satify resolution for this algorithm to can work well and more adjust resolution more good when streaming

7. To solve it, I must follow rule of h264 algorithm to find a satify resolution for streaming

8. Test with many device, double test to make sure it work well and have no exception

## My experience about this:
1. Alway must understand correctly about technical issue
2. Should solve by you first, alway find a best solution before reference to some document. If the issue is rockly issue, then you can reference it, and use document in the good way to make sure we solve it more deeply and more perfectly
3. Use all of tool we can use to solve technical issue
4. list all of the ways we can solve it, then choose a best solution
5. break down issue to small issue to solve it in correct way and perfect way
6. understand deeply is the key for any technical issue
7. should know about algorithm / data structure knowledge, it's really useful 
8. solve and test carefully to make sure no side effect and make sure code we write more clean, easy to understand for other people


II. Other issue
- Sometime I design good architecture for project not satify with my expect, it's must work and follow CLEAN architect, SOLID rule. Some time it's take my time to consider choose a good solution
- Some technical issue I faced often because it's quite new to me, to learn it quickly, I must learn by practical, do some research base on example, small project, and choose best resource to read (Apple documentation, WWDC video, Medium, some good quality blog)
- Some technical have less comunity and document, in this case, I must research by myself and must understand the technical in deep, find the way to understand it in deep way and more productive way. First of all, I must keep good attitude, positive and balance, then I must break it to small task, and do step by step, to understand more deeply, more perfect
  


