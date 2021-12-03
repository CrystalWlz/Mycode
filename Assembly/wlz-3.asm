
DATA SEGMENT
;播放音乐所需数据 
    mayDAY_musFreq dw -1
    opplaying DB "OP:Sincerely",'$'
    opmusicInfo DB "For Violet Evergarden",'$'            ;标题
    sincerelyFreq DW 196,330,294,330,370,330,294,1,294,1,196,330,294,330,294,330,370,1,370,1;6323432,2,6323234,4,
                 DW 196,294,330,370,330,294,1,294,1,196,294,196,294,330,370,1;623432,2,626234,
                 DW 196,330,294,330,370,330,294,1,294,1,196,330,294,330,440,330,294,1,294,1;6323432,2,63236322,
                 DW 196,294,330,370,391,440,370,330,294,-1;623456432

    sincerelyTime DW 25,50,25,50,25,75,25,3,47,25,25,50,25,50,25,75,25,3,47,25
                 DW 25,50,50,50,125,25,3,47,25,25,50,25,50,25,150,25
                 DW 25,50,25,50,25,75,25,3,47,25,25,50,25,50,25,75,25,3,47,25
                 DW 25,50,25,75,25,75,25,25,125
        edplaying DB "ED: mi chi si ru be",'$'
        edmusicInfo DB "beng bu zhu le",'$'
        edFreq DW 262,1,262,1,262,294,262,294,330,1,391,330,294,262,1,262,1;1,1,12123,5321,1,
                DW 262,1,262,1,262,294,262,294,262,523,494,391,330,294,1,294,330,294,262,294,262,-1;1,1,12121!17532,232121
        edTime DW 90,10,45,10,45,100,50,50,300,50,100,100,150,50,10,190,100
                DW 90,10,45,10,45,100,50,50,100,100,150,25,25,90,10,50,50,100,50,50,200;连音需有5的间隔
        ;绘制星星所需数据
    starX DW 0
    starY DW 20
    rec1X DW 118
    rec1Y DW 175
    temp1 DW 0
    temp2 DW 0

    star db 0,0,0,0,1,1,0,0,0,0
         db 0,0,0,0,1,1,0,0,0,0 
         db 0,0,0,1,1,1,1,0,0,0 
         db 0,0,0,1,1,1,1,0,0,0 
         db 1,1,1,1,1,1,1,1,1,1 
         db 0,1,1,1,1,1,1,1,1,0 
         db 0,0,1,1,1,1,1,1,0,0 
         db 0,0,1,1,0,0,1,1,0,0 
         db 0,1,1,0,0,0,0,1,1,0 
         db 0,1,0,0,0,0,0,0,1,0
         ;显示图片所需数据
    MainPic db 'violet.bmp',0       ; 图片路径  
    ED db 'ed.bmp',0
    OP DB 'op.bmp',0
    x0 dw 0  	                ; 当前显示界面的横坐标，初始为0
    y0 dw 0            	        ; 当前显示界面的纵坐标，初始为0
    handle dw 0                 ; 文件指针  
    bmpdata1 db 256*4 dup(0)    ; 存放位图文件调色板  
    bmpdata2 db 61000 dup(0)    ; 存放位图信息,64k  
    bmpwidth dw 0               ; 位图宽度  
    bmplength dw 0              ; 位图长度 
    ;显示菜单
    MENU_TIP DB  7CH,"   Stars will fall  ",7CH,'$'
    TIPS1 DB     7CH,"  after pressing C  ",7CH,'$'
    TIPS2 DB     7CH," Date:D       Time:T",7CH,'$'
    TIPS3 DB     7CH,"  Start The Timer:C ",7CH,'$'
    TIPS4 DB     7CH,"  Stop The Timer:S  ",7CH,'$'
    TIPS5 DB     7CH," Restart The Timer:R",7CH,'$'
    TIPS6 DB     7CH,"   Play The ED:E    ",7CH,'$'    
    TIPS7 DB     7CH," Quit This Program:Q",7CH,'$'
    LINE_BREAK DB 0AH,0DH,'$'
    Info DB "Never know what love means.",'$'
    colorIndex DB 0F7H
    colorHigh DB 00H
    colorLow DB 08H
    BUFFER DB 1000 DUP(0)        ;通用缓冲区
    ;显示日期时间所需数据
    DATE DB "DATE:0000/00/00|000",'$','$'
    WEEK DB "MON","TUS","WED","THS","FRI","SAT","SUN" ;星期
    TIME DB "00:00:00",'$','$'
    DATE_X DB 2                ;图形模式下x坐标范围0~49,y坐标范围0~39 ，注意x为行数，y为列数，与图形坐标轴不一样。
    DATE_Y DB 4
    TIME_X DB 3
    TIME_Y DB 2
    CLK_NAME DB "CLK",'$'
    TIMER_NAME DB "TIMER",'$'
    showDate_Flag DB 0
    
    ;8253中断定时器所需数据
    count100 DB 0               ; 分频系数
    fre100 DB 0                 ; 100hz
    fre1000 DB 0                ; 1000hz
    tenHour db '0'              ; 小时的十位
    hour db '0',':'
    tenMin db '0'
    minute db '0',':'
    tenSec db '0'
    second db '0'
    timerStr db "00:00:00:0",'$'
    secUpdate db 0
    timerStart_Flag db 0
    timerStop_Flag db 0
    
    
DATA ENDS

STACK SEGMENT STACK 'STACK'
    DB 1024 DUP(0)
STACK ENDS

CODE SEGMENT 'CODE'
    ASSUME DS:DATA,SS:STACK,CS:CODE
;宏定义
;画星星     
DRAW_STAR MACRO X,Y,COLOR
        LOCAL ROWS,COLS,NEXT,setballcolor,setballexit
        mov bh,00                       ;显示页号为0 
        mov ah,0ch                      ;写像素，AL=颜色，BH=页码 CX=x，DX=y  
        mov si,-1                       ;将从第一个开始读 
        mov dx,y                        ;得到左上角的坐标 
        sub dx,1 
        mov cx,x 
        add cx,10
        ROWS:                           ;画行 
                mov bl,0 
                add dx,1      
                sub cx,10 
        COLS:                           ;画点 
                add bl,1                ;用于计数一行中的10个点 
                add cx,1 
                add si,1 
                mov al,color 
                cmp star[si],00 
                jne setstarcolor        ;是否为黑点 
                mov al,00 
        setstarcolor: 
                int 10h 
        
                cmp bl,10 
                jb COLS                 ;当一行中的10个点画完后，进入外循环  
                cmp si,99 
                jb ROWS                 ;当100个点全部画完后，跳出      
        setstarexit: 
        ENDM 
;音乐地址  
MUS_ADDRESS MACRO A,B
    LEA SI,A
    LEA BP,DS:B
    ENDM
;设置光标位置
SET_SHOW_POS MACRO POS_X,POS_Y
        MOV BH,0       ;页码
        mov DH,POS_X   ;行
        mov DL,POS_Y   ;列
        mov ah,02H      
        int 10h
        ENDM

;显示字符串
SHOW_STR MACRO STRING_NAME,STR_X,STR_Y
        SET_SHOW_POS STR_X,STR_Y
        LEA DX,STRING_NAME
        MOV AH,09H
        INT 21h
        ENDM
;显示彩色字符
SHOW_COLOR_CHAR MACRO CHAR,CHX,CHY,COLOR,TIMES
        SET_SHOW_POS CHX,CHY
        MOV CX,TIMES
        MOV AH,09H
        MOV AL,CHAR
        MOV BL,COLOR
        INT 10H
        ENDM


;宏定义END





START:
        ;设定段寄存器
        MOV AX,DATA
        MOV DS,AX
        MOV ES,AX

;主过程                            
BEGIN:         
        LEA DX,OP
        CALL OPEN_PHOTO                 ;读取op图片 
        CALL READ_PHOTO
        CALL SET_COLOR 
        CALL SHOW_IMG  
        SHOW_STR opplaying,10,16
        SHOW_STR opmusicInfo,12,10
        MUS_ADDRESS sincerelyFreq, sincerelyTime    ;播放OP
        CALL music                
MAIN_SHOW:
        CALL CLR_TIMER_STR
        CALL CLR_SRC
        LEA DX,MainPic
        CALL OPEN_PHOTO                 ;读取主界面图片 
        CALL READ_PHOTO
        CALL SET_COLOR 
        CALL SHOW_IMG                   ;显示图片
        CALL SHOW_TIPS                  ;显示提示信息
;主循环
MAIN_LOOP:         
        MOV AH,01H                      ;键盘输入
        INT 16H     
        JNZ SCAN_BUTTON                 ;判断输入
        SHOW_STR CLK_NAME,1,2
        SHOW_STR TIME,2,2              ;显示时钟
        CMP showDate_Flag,1             ;是否显示日期
        JNE NSD
        CALL GET_DATE
        SHOW_STR DATE,DATE_Y,DATE_X
        NSD:
        CMP timerStop_Flag,1
        JE NEXT1
        SHOW_STR TIMER_NAME,6,2
        SHOW_STR timerStr,7,2           ;显示计时器           
        NEXT1:
                CMP timerStart_Flag,1           
                JE TIMER_START          ;启动8253定时器
                CALL GET_TIME
                JMP MAIN_LOOP
        TIMER_START:
                CMP secUpdate,1                 ;8253的秒位发生变化
                JAE SEC_PASSED
                CALL UPDATE_TIMER_STR
                JMP MAIN_LOOP
        SEC_PASSED:
                CMP timerStop_Flag,1
                JE NSTAR     
                CALL CLR_SRC  
                CALL SHOW_IMG                   
                CALL SHOW_TIPS
                CALL DRAW_STARS         ;显示星星       
                NSTAR:                 
                MOV secUpdate,0         ;时间复位
                CALL GET_TIME_FROM_CLK
                JMP MAIN_LOOP
        SCAN_BUTTON:
                MOV AH,00H
                INT 16H                 ;将缓冲区的字符读走，使缓冲区清空
                CMP AL,'t'
                JE PRESS_T
                CMP AL,'d'
                JE PRESS_D
                CMP AL,'q'
                JE PRESS_Q
                CMP AL,'c'
                JE PRESS_C
                CMP AL,'s'
                JE PRESS_S
                CMP AL,'r'
                JE PRESS_R
                CMP AL,'e'
                JE PRESS_E
                CMP AX,4b00h            ;左方向键
                JE PRESS_LEFT
                CMP AX,4D00H            ;右方向键
                JE PRESS_RIGHT
                CMP AX,4800H            ;上方向键
                JE PRESS_UP
                CMP AX,5000H            ;下方向键
                JE PRESS_DOWN
                
                JMP MAIN_LOOP

                PRESS_UP:
                        MOV AL,timerStart_Flag
                        CMP AL,1
                        JE EXIT_CHANGE_DATE_POS
                        SUB DATE_Y,2
                        CALL SHOW_IMG
                        CALL SHOW_TIPS
                        SHOW_STR DATE,DATE_Y,DATE_X
                        JMP MAIN_LOOP
                PRESS_DOWN:
                        MOV AL,timerStart_Flag
                        CMP AL,1
                        JE EXIT_CHANGE_DATE_POS
                        ADD DATE_Y,2
                        CALL SHOW_IMG
                        CALL SHOW_TIPS
                        SHOW_STR DATE,DATE_Y,DATE_X
                        JMP MAIN_LOOP
                PRESS_LEFT:  
                        ; INC colorIndex
                        MOV AL,timerStart_Flag
                        CMP AL,1
                        JE EXIT_CHANGE_DATE_POS
                        SUB DATE_X,2
                        CALL SHOW_IMG
                        CALL SHOW_TIPS
                        SHOW_STR DATE,DATE_Y,DATE_X
                        JMP MAIN_LOOP
                PRESS_RIGHT:
                        ; DEC colorIndex
                        MOV AL,timerStart_Flag
                        CMP AL,1
                        JE EXIT_CHANGE_DATE_POS
                        ADD DATE_X,2
                        CALL SHOW_IMG
                        CALL SHOW_TIPS
                        SHOW_STR DATE,DATE_Y,DATE_X
                EXIT_CHANGE_DATE_POS:
                        JMP MAIN_LOOP
                PRESS_D:
                        CALL GET_DATE
                        MOV showDate_Flag,1
                        JMP MAIN_LOOP
                PRESS_T:
                        JMP MAIN_LOOP
                PRESS_C:
                        MOV timerStart_Flag,1
                        MOV timerStop_Flag,0
                        CALL TIMER_INIT          ;定时器初始化
                        CALL TIMER_ENABLE       ;定时器使能 
                        CALL DRAW_STARS                      
                        JMP MAIN_LOOP
                PRESS_S:        
                        ;MOV timerStart_Flag,0
                        MOV timerStop_Flag,1
                        JMP MAIN_LOOP
                PRESS_R:
                        CALL CLR_TIMER_STR
                        CALL CLR_TIMER
                        CALL SHOW_IMG
                        CALL SHOW_TIPS
                        MOV starY,1
                        MOV starX,1
                        SHOW_STR TIMER_NAME,6,2
                        SHOW_STR timerStr,7,2
                        JMP MAIN_SHOW
                PRESS_E:
                        LEA DX,ED
                        CALL CLR_SRC
                        CALL OPEN_PHOTO
                        CALL READ_PHOTO
                        CALL SHOW_IMG
                        SHOW_STR edplaying,20,20
                        SHOW_STR edmusicInfo,21,20
                        MUS_ADDRESS edFreq, edTime    ;播放ed
                        CALL music
                        JMP MAIN_SHOW
                PRESS_Q:
                        JMP EXIT_MAIN
;主循环END
EXIT_MAIN:
        ; MOV AH,0                        ;等待键盘输入后退出
        ; INT 16H
        mov ax, 3  	                  ;返回窗口
        int 10h
        MOV AH,4CH
        INT 21H






;子过程定义
; CLR_SRC
; 清屏
CLR_SRC PROC
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        MOV AX,0600H	
	MOV BH,07H
	MOV CX,0
	MOV DX,204FH
	INT 10H
        POP DX
        POP CX
        POP BX
        POP AX
        RET
CLR_SRC ENDP
; music
; 播放音乐
music proc near
     xor ax, ax
freg:
     mov di, [si]       ;di为频率
     cmp di, 0FFFFH     ;若为-1则停止播放
     je end_mus
     mov bx, ds:[bp]    ;bx为节拍
     call GEN_SOUND
     add si, 2
     add bp, 2
     jmp freg
end_mus:
     ret
music endp

; GEN_SOUND
; 发声
GEN_SOUND proc near
    push ax
    push bx
    push cx
    push dx
    push di
    PUSH SI

    CMP DI,1            ;频率表中1代表此时不发声
    JE  wait1

    mov al, 0b6H
    out 43h, al         ;使能8253
    mov dx, 12h
    mov ax, 348ch
    div di              ;获取所需频率送al，再传给8253
    out 42h, al
 
    mov al, ah
    out 42h, al
 
    in al, 61h
    mov ah, al
    or al, 3
    out 61h, al         ;打开扬声器

wait1:
    mov cx, 3314
    call waitf
    push cx             ;保护
delay1:
    pop cx
    dec bx
    jnz wait1
    mov al, ah
    out 61h, al
    POP SI
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
GEN_SOUND endp
; DRAW_STARS
; 画星星
DRAW_STARS PROC
         ADD starY,30
         CMP starY,190
         JL OKy
         MOV starY,1
         ADD starX,50
        OKy:
        CMP starX,310
        JL OKx
        MOV starX,1
        OKx:
        DRAW_STAR starX,starY,27H
        RET
DRAW_STARS ENDP
; SHOW_TIPS
; 显示提示信息
SHOW_TIPS PROC        
        PUSH AX
        PUSH DX
        SHOW_COLOR_CHAR '~',9,1,0DH,22
        SHOW_STR MENU_TIP,10,1
        SHOW_STR TIPS1,11,1
        SHOW_STR TIPS2,12,1
        SHOW_STR TIPS3,13,1
        SHOW_STR TIPS4,14,1
        SHOW_STR TIPS5,15,1
        SHOW_STR TIPS6,16,1
        SHOW_STR TIPS7,17,1
        SHOW_COLOR_CHAR '~',18,1,0DH,22
        SHOW_STR Info,20,1
        POP DX
        POP AX
        RET
SHOW_TIPS ENDP

; GET_TIME
; 获取时间，并填充TIME数组
; 寄存器：ch,cl,dh中分别存放时分秒
GET_TIME PROC
        PUSH AX
        PUSH BX
        PUSH DX
        MOV AH,2CH      ;获取系统时间
        INT 21H
        XOR AX,AX   
        CALL CLR_TIME 
        ; 00:00:00   
        ;转换小时为ASC2
        MOV AL,CH
        LEA BX,TIME+1
        CALL NUM2ASC
        LEA BX,TIME+4
        ;转换分
        MOV AL,CL
        CALL NUM2ASC
        LEA BX,TIME+7
        ;转换秒
        MOV AL,DH
        CALL NUM2ASC
        ADD BX,3
        POP DX
        POP BX
        POP AX
        RET
GET_TIME ENDP

; GET_TIME_FROM_CLK
; 从定时器继续当前时钟
GET_TIME_FROM_CLK PROC FAR
        ;00:00:00
        PUSH AX
        PUSH BX
        LEA BX,TIME
        INC BYTE PTR[BX+7]      ;秒个位
        MOV AL,[BX+7]
        CMP AL,'9'
        JLE RET1
        MOV BYTE PTR[BX+7],'0'
        INC BYTE PTR[BX+6]      ;秒十位
        MOV AL,[BX+6]
        CMP AL,'5'
        JLE RET1
        MOV BYTE PTR[BX+6],'0'
        INC BYTE PTR[BX+4]      ;分个位
        MOV AL,[BX+4]
        CMP AL,'9'
        JLE RET1
        MOV BYTE PTR[BX+4],'0'
        INC BYTE PTR[BX+3]      ;分十位
        MOV AL,[BX+3]
        CMP AL,'5'
        JLE RET1
        MOV BYTE PTR[BX+3],'0'
        INC BYTE PTR[BX+1]      ;时个位
        MOV AL,[BX+1]
        CMP AL,'3'
        JLE RET1
        MOV BYTE PTR[BX+1],'0'
        INC BYTE PTR[BX]      ;时十位
        MOV AL,[BX]
        CMP AL,'2'
        JLE RET1
        MOV BYTE PTR[BX],'0' 
        RET1:   
        POP BX
        POP AX
        RET
GET_TIME_FROM_CLK ENDP

; CLR_TIME
; 清空TIME数组
CLR_TIME PROC FAR
        PUSH BX
        MOV BX,OFFSET TIME
        MOV BYTE PTR[BX],'0'
        MOV BYTE PTR[BX+1],'0'
        MOV BYTE PTR[BX+2],':'
        MOV BYTE PTR[BX+3],'0'
        MOV BYTE PTR[BX+4],'0'
        MOV BYTE PTR[BX+5],':'
        MOV BYTE PTR[BX+6],'0'
        MOV BYTE PTR[BX+7],'0'
        POP BX
        RET
CLR_TIME ENDP

;SHOW_TIME
; 显示日期
SHOW_TIME PROC
        PUSH DX 
        PUSH AX
        SHOW_STR TIME,TIME_X,TIME_Y
        POP AX
        POP DX
SHOW_TIME ENDP

; GET_DATE
; 获取日期，并填充给DATE数组
; 寄存器：CX,DH,DL,AL
GET_DATE PROC  
        PUSH AX
        PUSH CX
        PUSH DX
        ;DATE:xxxx/xx/xx xxx
        MOV AH,2AH      ;取日期
        INT 21H
        PUSH AX         ;传参需要用到AX，而AL又存储着星期

        MOV AX,CX       ;转换年
        MOV BX,OFFSET DATE+4+4
        CALL NUM2ASC    
        
        LEA BX,DATE+11
        MOV AX,DX
        MOV CL,8
        SHR AX,CL       ;转换月 
        CALL NUM2ASC

        LEA BX,DATE+14
        MOV AX,DX       ;转换日
        AND AX,00FFH    ;屏蔽AH
        CALL NUM2ASC
        ADD BX,2+1+1    ;指向星期的开头，而不是末尾,所以是2+1+1不是2+1+3

        POP AX          ;取回星期
        AND AX,00FFH    ;屏蔽AH
        CMP AL,0        ;DOS中星期日时AL为0，比较特殊
        JE SUNDAY
        ;获取WEEK数组的偏移量以取得正确的星期字符，偏移量=（星期数-1）*3
        MOV DL,AL       ;作为乘数
        DEC DL          ;星期一的偏移量应为0
        MOV AL,3
        MUL DL          ;乘积送AX
        SUNDAY:
        MOV AX,18
        LEA SI,WEEK
        ADD SI,AX       ;加上偏移量
        MOV CX,3        ;给DATE存入星期字符
        
        STORE:  
        MOV AL,[SI]
        MOV [BX],AL
        INC BX
        INC SI
        LOOP STORE
        POP DX
        POP CX
        POP AX
        RET
GET_DATE ENDP

; SHOW_DATE
; 显示日期
; 寄存器：DX,AH
; 出口参数：无
SHOW_DATE PROC
        PUSH DX
        PUSH AX
        SET_SHOW_POS DATE_X,DATE_Y
        LEA DX,DATE
        MOV AH,09H  
        INT 21H
        CALL PRINT_LINE_BREAK
        POP AX
        POP DX
        RET
SHOW_DATE ENDP

; NUM2ASC
; 将数字转为ASC2码形式
; 寄存器：BX,AX
; AX存待转换数字，BX存字符串末尾
; 出口参数：BX指向字符串末尾的下一个位置
NUM2ASC PROC
        PUSH DX
        MOV SI,10
        NEXT:   
        XOR DX,DX
        DIV SI          ; 从最高位开始逐位转换
        ADD DX,'0'
        MOV [BX],DL     ;转换结果存入字符串中
        DEC BX          ;指向下一个位置(由于从最高位开始转换，因此需要让指针减量，以实现高位存高地址)
        OR AX,AX        ;检查ZF,是否还有位需要转换
        JNZ NEXT
        POP DX
        RET
NUM2ASC ENDP

; PRINT_LINE_BREAK
; 打印一个换行符
PRINT_LINE_BREAK PROC
        PUSH DX
        PUSH AX
        LEA DX,LINE_BREAK
        MOV AH,09H
        INT 21H
        POP AX
        POP DX
        RET
PRINT_LINE_BREAK ENDP

; OPEN_PHOTO
; 打开图片文件
; DX存图片路径名
OPEN_PHOTO PROC NEAR  
;     LEA DX, MainPic           
    MOV AH, 3DH  
    MOV AL, 0  
    INT 21h  	
    MOV handle, AX  
    RET  
OPEN_PHOTO ENDP  

; READ_PHOTO
; 读取图片文件，获取位图信息函数  
READ_PHOTO proc near  
        ; 移动文件指针,bx = 文件代号， cx:dx = 位移量， al = 0 即从文件头绝对位移  
        mov ah, 42h  
        mov al, 0  
        mov bx, handle  
        mov cx, 0  
        mov dx, 12h             ; 跳过18个字节直接指向位图的宽度信息  
        int 21h  
        ; 读取文件，ds:dx = 数据缓冲区地址, bx = 文件代号, cx = 读取的字节数, ax = 0表示已到文件尾  
        mov ah, 3fh  
        lea dx, bmpwidth        ; 存放位图宽度信息  
        mov cx, 2  
        int 21h  
        ;操作同上，获取位图长度信息
        mov ah, 42h  
        mov al, 0  
        mov bx, handle  
        mov cx, 0  
        mov dx, 16h             ; 跳过22个字节直接指向位图的长度信息  
        int 21h  
        mov ah, 3fh  
        lea dx, bmplength       ; 存放位图长度信息  
        mov cx, 2  
        int 21h                          
	; 读取位图颜色信息    
        ; 跳过前54个字节进入颜色信息  
        mov ah, 42h  
        mov al, 0  
        mov bx, handle  
        mov cx, 0  
        mov dx, 36h     
        int 21h  
        mov ah, 3fh  
        lea dx, bmpdata1        ; 将颜色信息放入bmpdata1  
        mov cx, 256*4           ; 蓝+绿+红+色彩保留（0）一共占256*4个字节  
        int 21h  
        ret  
READ_PHOTO endp  

; SET_COLOR
; 设置调色板输出色彩索引号及rgb数据共写256次   
SET_COLOR proc near  
        ;设置256色,320*200像素  640*480
        mov ax, 0013h  
        int 10h   
        ; MOV AX,4F02H
        ; MOV BX,103H
        ; INT 10H
        mov cx, 256  
        lea si, bmpdata1         ; 颜色信息  
        l0:    
        mov dx, 3c8h             ; 设定i/o端口  
        mov ax, cx  
        dec ax  
        neg ax                   ; 求补  
        add ax, 255              ; ax = ffffh(al = ffh, ah = ffh)  
        out dx, al               ; 将al中的数据传入dx指向的i/o端口中  
        inc dx  
        ; bmp调色板存放格式：bgrAlphabgrAlpha...(Alpha为空00h)  
        ; rgb/4后写入，显卡要求，rgb范围(0~63)，位图中(0~255)  
        mov al, [si+2]           ;r通道
        shr al, 1                
        shr al, 1  
        out dx, al  
        mov al, [si+1]  	 ;g通道	
        shr al, 1  
        shr al, 1  
        out dx, al  
        mov al, [si]  		 ;b通道
        shr al, 1  
        shr al, 1  
        OUT dx, al  
        add si, 4  
        loop l0  
        ret  
SET_COLOR endp  

; SHOW_IMG
; 显示图片
SHOW_IMG proc near  
        mov bx, 0a000h          ; 写屏 
        mov es, bx  
l1:  	xor di,di  
        cld                     ; df清零  
        mov cx, y0              ; cx = 0  
l2:  	mov ax, bmpwidth        ; ax = 位图宽度  
        mov dx, ax  
        and dx, 11b  	        ;位图宽度是否为4倍数
        jz  l3  
        mov ax, 4  
        sub ax, dx  
        add ax, bmpwidth  	;填充
l3:  	inc cx			;cx行数
        mul cx  				
        mov bx, 0  
        sub bx, ax  
        mov ax, bx  			
        mov bx, 0  
        sbb bx, dx  
        mov dx, bx  			
        push cx  
        mov cx, dx  
        mov dx, ax  
        mov bx, handle  
        mov ax, 4202h  		;向前移动cxdx个字节，无符号
        int 21h  
        lea dx, bmpdata2  
        mov cx, bmpwidth  
        mov ah, 3fh  
        int 21h  
        pop cx  
        cmp ax, bmpwidth  
        jb  l7  
        lea si, bmpdata2  
        add si, x0 
	push di  
        xor dx,dx   
l5:     lodsb  
        stosb  			;[si] -> [di],si++,di++
        inc dx  
        cmp dx, 320     ;320
        jae l6  
        push dx  
        add dx, x0  
        cmp dx, bmpwidth  
        pop dx  
        jb  l5  
l6:     pop di  
        add di, 320     ;320
        push cx  
        sub cx, y0  
        cmp cx, 200     ;200
        pop cx  
        jae l7    
        cmp cx, bmplength  
        jb  l2 
l7:
        jmp exit        
exit:   
        RET      
SHOW_IMG endp 

; TIMER_INIT
; 初始化8253中断定时器
TIMER_INIT PROC
        PUSH BX
        PUSH AX
        ;中断服务程序的装载
        CLI             ;使if=0,禁止中断
        MOV AX,0;       ;直接写入法，把中断服务程序地址写入中断向量表
        MOV ES,AX       ;表段地址      
        MOV DI,20H      ;表偏移地址=8*4=32=20h，将timer中断程序放入中断地址表08h的位置中
        MOV AX,OFFSET TIMER     ;获取timer地址
        STOSW           ;写入偏移地址
        MOV AX,CS       ;获取段地址（其实就是cs
        STOSW           ;写入段地址

        ;定时器参数配制，使用通道0，每秒中断100次
        MOV AL,36H
        OUT 43H,AL
        MOV BX,11932
        MOV AL,BL
        OUT 40H,AL 
        MOV AL,BH
        OUT 40H,AL 

        POP AX
        POP BX
        RET
TIMER_INIT ENDP

; TIMER_ENABLE
; 使能定时中断
TIMER_ENABLE PROC
        MOV AL,0FCH
        OUT 21H,AL      ;写中断掩码寄存器
        STI             ;if置1，使能8086中断
        RET
TIMER_ENABLE ENDP

; TIMER
; 定时中断服务程序
TIMER PROC FAR
        PUSH AX
        PUSH BX
        MOV fre1000,1
        INC count100
        MOV AL,100
        MOV BL,count100
        CMP BL,AL
        JBE TIMERX
        MOV count100,0        ;1秒，计数溢出后重置计数器
        ADD secUpdate,1
        INC second
        CMP second,'9'
        JLE TIMERX
        MOV second,'0'
        INC tenSec
        CMP tenSec,'6'
        JL TIMERX
        MOV tenSec,'0'
        INC minute
        CMP minute,'9'
        JLE TIMERX
        MOV minute,'0'
        INC tenMin
        CMP tenMin,'6'
        JL TIMERX
        MOV tenMin,'0'
        INC hour
        CMP hour,'9'
        JA ADDHOUR
        CMP HOUR,'3'
        JNZ TIMERX
        CMP tenHour,'1'
        JNZ TIMERX
        MOV hour,'1'
        MOV tenHour,'0'
        JMP SHORT TIMERX
ADDHOUR:
        INC tenHour
        MOV hour,'0'
TIMERX:
        MOV AL,20H      ;XT机的话得给8259A中断结束命令
        OUT 20H,AL

        POP BX
        POP AX
        IRET                    ;中断返回
TIMER ENDP

; UPDATE_TIMER
;  更新计时器显示字符串
UPDATE_TIMER_STR PROC
        PUSH AX
        PUSH BX
        PUSH DX
        ;00:00:00:0
        XOR AX,AX
        CMP timerStart_Flag,0
        JE EXIT_UPDATE_TIMER
        MOV AL,count100         
        MOV DX,10
        DIV DL                  ;AL存十位，AH存个位
        ADD AL,30H
        ; ADD AH,30H
        LEA BX,timerStr         ;获取偏移量
        MOV BYTE PTR[BX+9],AL
        ; MOV BYTE PTR[BX+10],AH
        MOV AL,tenHour
        MOV BYTE PTR[BX],AL
        MOV AL,hour
        MOV BYTE PTR[BX+1],AL
        MOV AL,tenMin
        MOV BYTE PTR[BX+3],AL
        MOV AL,minute
        MOV BYTE PTR[BX+4],AL
        MOV AL,tenSec
        MOV BYTE PTR[BX+6],AL
        MOV AL,second
        MOV BYTE PTR[BX+7],AL
EXIT_UPDATE_TIMER:
        POP DX 
        POP BX 
        POP AX
        RET
UPDATE_TIMER_STR ENDP

CLR_TIMER_STR PROC
        PUSH BX
        LEA BX,timerStr
        MOV BYTE PTR [BX],'0'
        MOV BYTE PTR [BX+1],'0'
        MOV BYTE PTR [BX+3],'0'
        MOV BYTE PTR [BX+4],'0'
        MOV BYTE PTR [BX+6],'0'
        MOV BYTE PTR [BX+7],'0'
        MOV BYTE PTR [BX+9],'0'
        POP BX
        RET
CLR_TIMER_STR ENDP

CLR_TIMER PROC
        MOV second,'0'
        MOV tenSec,'0'
        MOV minute,'0'
        MOV tenMin,'0'
        MOV hour,'0'
        MOV tenHour,'0'
        RET
CLR_TIMER ENDP

; DISP_CLK
; 显示定时器时间
DISP_CLK PROC
        PUSH BX
        PUSH AX
        MOV BX,OFFSET tenHour
        MOV CX,8
DISP_LOOP:
        MOV AL,[BX]     ;AL存待显示字符
        CALL DISP_CHAR
        INC BX
        LOOP DISP_LOOP
        POP AX
        POP BX
        RET 
DISP_CLK ENDP

; DISP_CHAR
; 显示一个字符
; AL存放待显示字符
DISP_CHAR PROC
        PUSH BX
        MOV BX,0
        MOV AH,14
        INT 10h
        POP BX
        RET
DISP_CHAR ENDP



; WAITF
; 延时程序
WAITF proc near
     push ax
waitf1:
     in al,61h
     and al,10h
     cmp al,ah
     je waitf1
     mov ah,al
     loop waitf1
     pop ax
     ret
WAITF endp

CODE ENDS
    END START