#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <sys/socket.h>
#include <resolv.h>
#include <stdlib.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <sys/time.h>
#include <sys/types.h>

#define MAXBUF 1024

/************关于本文档********************************************
// *filename: ssync-client.c
*purpose: 演示网络异步通讯，这是客户端程序
*wrote by: zhoulifa(zhoulifa@163.com) 周立发(http://zhoulifa.bokee.com)
Linux爱好者 Linux知识传播者 SOHO族 开发者 最擅长C语言
*date time:2007-01-25 21:32
*Note: 任何人可以任意复制代码并运用这些文档，当然包括你的商业用途
* 但请遵循GPL
*Thanks to: Google.com
*Hope:希望越来越多的人贡献自己的力量，为科学技术发展出力
* 科技站在巨人的肩膀上进步更快！感谢有开源前辈的贡献！
*********************************************************************/

int main(int argc, char **argv)
{
    int sockfd, len;
    struct sockaddr_in dest;
    char buffer[MAXBUF + 1];

    fd_set rfds;
    struct timeval tv;
    int retval, maxfd = -1;

    // if (argc != 3) 
    // {
    //     printf("参数格式错误！正确用法如下：\n\t\t%s IP地址 端口\n\t比如:\t%s 127.0.0.1 80\n此程序用        来从某个 IP 地址的服务器某个端口接收最多 MAXBUF 个字节的消息",argv[0], argv[0]);

    //     exit(0);
    // }

    /* 创建一个 socket 用于 tcp 通信 */
    if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) < 0)
    {
        perror("Socket");
        exit(errno);
    }

    /* 初始化服务器端（对方）的地址和端口信息 */
    bzero(&dest, sizeof(dest));
    dest.sin_family = AF_INET;
    dest.sin_addr.s_addr = inet_addr(argv[1]);  /* IP address */
<<<<<<< HEAD
    dest.sin_port = htons(8003);
    // if (inet_aton("106.75.100.229", (struct in_addr *) &dest.sin_addr.s_addr) == 0) 
    // {
    //     perror(argv[1]);
    //     exit(errno);
    // }
=======
    dest.sin_port = htons(6666);
    if (inet_aton(argv[1], (struct in_addr *) &dest.sin_addr.s_addr) == 0) 
    {
        perror(argv[1]);
        exit(errno);
    }
>>>>>>> 14958f923dcaf701525919896818943eda9477cd

    /* 连接服务器 */
    if (connect(sockfd, (struct sockaddr *) &dest, sizeof(dest)) != 0) 
    {
        perror("Connect error ");
        exit(errno);
    }

    printf("client ready!\n");

    while (1) 
    {
        /* 把集合清空 */
        FD_ZERO(&rfds);
        /* 把标准输入句柄0加入到集合中 */
        FD_SET(0, &rfds);
        maxfd = 0;

        /* 把当前连接句柄sockfd加入到集合中 */
        FD_SET(sockfd, &rfds);

        if (sockfd > maxfd)
        {
            maxfd = sockfd;
        }
        
        /* 设置最大等待时间 */
        tv.tv_sec = 1;
        tv.tv_usec = 0;

        /* 开始等待 */
        retval = select(maxfd + 1, &rfds, NULL, NULL, &tv);

        if (retval == -1)
        {
            printf("select error: %s, will exit!", strerror(errno));
            break;
        }
        else if (retval == 0) 
        {
            /* printf("没有任何消息到来，用户也没有按键，继续等待……\n"); */
            continue;
        } 
        else 
        {
            if (FD_ISSET(sockfd, &rfds)) 
            {
                /* 连接的socket上有消息到来则接收对方发过来的消息并显示 */
                bzero(buffer, MAXBUF + 1);

                /* 接收对方发过来的消息，最多接收 MAXBUF 个字节 */
                len = recv(sockfd, buffer, MAXBUF, 0);
                if (len > 0)
                {
                    printf("%s\n",buffer);
                }
                else 
                {
                    if (len < 0)
                    {
                        printf("recv error no:%d，errotstring: '%s'\n",errno, strerror(errno));
                    }
                    else
                    {
                        printf("sever exit！\n");
                    }

                    break;
                }
            }

            if (FD_ISSET(0, &rfds))
            {
                /* 用户按键了，则读取用户输入的内容发送出去 */
                bzero(buffer, MAXBUF + 1);
                fgets(buffer, MAXBUF, stdin);

                if(!strncasecmp(buffer, "quit", 4)) 
                {
                    printf("自己请求终止聊天！\n");
                    break;
                }

                /* 发消息给服务器 */
                len = send(sockfd, buffer, strlen(buffer) - 1, 0);
                if (len < 0)
                {
                    printf("send '%s'！error no:%d，string:'%s'\n",buffer, errno, strerror(errno));
                    break;
                } 
                else
                {
                    printf("client send %d data:%s", len, buffer);
                }
            }
        }
    }

    /* 关闭连接 */
    close(sockfd);
    return 0;
}