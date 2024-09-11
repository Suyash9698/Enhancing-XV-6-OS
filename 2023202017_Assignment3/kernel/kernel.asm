
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	cb010113          	add	sp,sp,-848 # 80008cb0 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	add	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	add	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	add	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	sllw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	add	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	sll	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	sll	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	b2070713          	add	a4,a4,-1248 # 80008b70 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	f4e78793          	add	a5,a5,-178 # 80005fb0 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	or	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	or	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	add	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	add	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	add	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	add	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc01f>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	add	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	dc678793          	add	a5,a5,-570 # 80000e72 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	add	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	or	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srl	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	add	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	add	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	add	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	add	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	5ec080e7          	jalr	1516(ra) # 80002716 <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	780080e7          	jalr	1920(ra) # 800008ba <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addw	s2,s2,1
    80000144:	0485                	add	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	add	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	711d                	add	sp,sp,-96
    80000166:	ec86                	sd	ra,88(sp)
    80000168:	e8a2                	sd	s0,80(sp)
    8000016a:	e4a6                	sd	s1,72(sp)
    8000016c:	e0ca                	sd	s2,64(sp)
    8000016e:	fc4e                	sd	s3,56(sp)
    80000170:	f852                	sd	s4,48(sp)
    80000172:	f456                	sd	s5,40(sp)
    80000174:	f05a                	sd	s6,32(sp)
    80000176:	ec5e                	sd	s7,24(sp)
    80000178:	1080                	add	s0,sp,96
    8000017a:	8aaa                	mv	s5,a0
    8000017c:	8a2e                	mv	s4,a1
    8000017e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000180:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000184:	00011517          	auipc	a0,0x11
    80000188:	b2c50513          	add	a0,a0,-1236 # 80010cb0 <cons>
    8000018c:	00001097          	auipc	ra,0x1
    80000190:	a46080e7          	jalr	-1466(ra) # 80000bd2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000194:	00011497          	auipc	s1,0x11
    80000198:	b1c48493          	add	s1,s1,-1252 # 80010cb0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000019c:	00011917          	auipc	s2,0x11
    800001a0:	bac90913          	add	s2,s2,-1108 # 80010d48 <cons+0x98>
  while(n > 0){
    800001a4:	09305263          	blez	s3,80000228 <consoleread+0xc4>
    while(cons.r == cons.w){
    800001a8:	0984a783          	lw	a5,152(s1)
    800001ac:	09c4a703          	lw	a4,156(s1)
    800001b0:	02f71763          	bne	a4,a5,800001de <consoleread+0x7a>
      if(killed(myproc())){
    800001b4:	00001097          	auipc	ra,0x1
    800001b8:	7f2080e7          	jalr	2034(ra) # 800019a6 <myproc>
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	3a4080e7          	jalr	932(ra) # 80002560 <killed>
    800001c4:	ed2d                	bnez	a0,8000023e <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001c6:	85a6                	mv	a1,s1
    800001c8:	854a                	mv	a0,s2
    800001ca:	00002097          	auipc	ra,0x2
    800001ce:	f96080e7          	jalr	-106(ra) # 80002160 <sleep>
    while(cons.r == cons.w){
    800001d2:	0984a783          	lw	a5,152(s1)
    800001d6:	09c4a703          	lw	a4,156(s1)
    800001da:	fcf70de3          	beq	a4,a5,800001b4 <consoleread+0x50>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	00011717          	auipc	a4,0x11
    800001e2:	ad270713          	add	a4,a4,-1326 # 80010cb0 <cons>
    800001e6:	0017869b          	addw	a3,a5,1
    800001ea:	08d72c23          	sw	a3,152(a4)
    800001ee:	07f7f693          	and	a3,a5,127
    800001f2:	9736                	add	a4,a4,a3
    800001f4:	01874703          	lbu	a4,24(a4)
    800001f8:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001fc:	4691                	li	a3,4
    800001fe:	06db8463          	beq	s7,a3,80000266 <consoleread+0x102>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000202:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000206:	4685                	li	a3,1
    80000208:	faf40613          	add	a2,s0,-81
    8000020c:	85d2                	mv	a1,s4
    8000020e:	8556                	mv	a0,s5
    80000210:	00002097          	auipc	ra,0x2
    80000214:	4b0080e7          	jalr	1200(ra) # 800026c0 <either_copyout>
    80000218:	57fd                	li	a5,-1
    8000021a:	00f50763          	beq	a0,a5,80000228 <consoleread+0xc4>
      break;

    dst++;
    8000021e:	0a05                	add	s4,s4,1
    --n;
    80000220:	39fd                	addw	s3,s3,-1

    if(c == '\n'){
    80000222:	47a9                	li	a5,10
    80000224:	f8fb90e3          	bne	s7,a5,800001a4 <consoleread+0x40>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000228:	00011517          	auipc	a0,0x11
    8000022c:	a8850513          	add	a0,a0,-1400 # 80010cb0 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	a56080e7          	jalr	-1450(ra) # 80000c86 <release>

  return target - n;
    80000238:	413b053b          	subw	a0,s6,s3
    8000023c:	a811                	j	80000250 <consoleread+0xec>
        release(&cons.lock);
    8000023e:	00011517          	auipc	a0,0x11
    80000242:	a7250513          	add	a0,a0,-1422 # 80010cb0 <cons>
    80000246:	00001097          	auipc	ra,0x1
    8000024a:	a40080e7          	jalr	-1472(ra) # 80000c86 <release>
        return -1;
    8000024e:	557d                	li	a0,-1
}
    80000250:	60e6                	ld	ra,88(sp)
    80000252:	6446                	ld	s0,80(sp)
    80000254:	64a6                	ld	s1,72(sp)
    80000256:	6906                	ld	s2,64(sp)
    80000258:	79e2                	ld	s3,56(sp)
    8000025a:	7a42                	ld	s4,48(sp)
    8000025c:	7aa2                	ld	s5,40(sp)
    8000025e:	7b02                	ld	s6,32(sp)
    80000260:	6be2                	ld	s7,24(sp)
    80000262:	6125                	add	sp,sp,96
    80000264:	8082                	ret
      if(n < target){
    80000266:	0009871b          	sext.w	a4,s3
    8000026a:	fb677fe3          	bgeu	a4,s6,80000228 <consoleread+0xc4>
        cons.r--;
    8000026e:	00011717          	auipc	a4,0x11
    80000272:	acf72d23          	sw	a5,-1318(a4) # 80010d48 <cons+0x98>
    80000276:	bf4d                	j	80000228 <consoleread+0xc4>

0000000080000278 <consputc>:
{
    80000278:	1141                	add	sp,sp,-16
    8000027a:	e406                	sd	ra,8(sp)
    8000027c:	e022                	sd	s0,0(sp)
    8000027e:	0800                	add	s0,sp,16
  if(c == BACKSPACE){
    80000280:	10000793          	li	a5,256
    80000284:	00f50a63          	beq	a0,a5,80000298 <consputc+0x20>
    uartputc_sync(c);
    80000288:	00000097          	auipc	ra,0x0
    8000028c:	560080e7          	jalr	1376(ra) # 800007e8 <uartputc_sync>
}
    80000290:	60a2                	ld	ra,8(sp)
    80000292:	6402                	ld	s0,0(sp)
    80000294:	0141                	add	sp,sp,16
    80000296:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000298:	4521                	li	a0,8
    8000029a:	00000097          	auipc	ra,0x0
    8000029e:	54e080e7          	jalr	1358(ra) # 800007e8 <uartputc_sync>
    800002a2:	02000513          	li	a0,32
    800002a6:	00000097          	auipc	ra,0x0
    800002aa:	542080e7          	jalr	1346(ra) # 800007e8 <uartputc_sync>
    800002ae:	4521                	li	a0,8
    800002b0:	00000097          	auipc	ra,0x0
    800002b4:	538080e7          	jalr	1336(ra) # 800007e8 <uartputc_sync>
    800002b8:	bfe1                	j	80000290 <consputc+0x18>

00000000800002ba <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ba:	1101                	add	sp,sp,-32
    800002bc:	ec06                	sd	ra,24(sp)
    800002be:	e822                	sd	s0,16(sp)
    800002c0:	e426                	sd	s1,8(sp)
    800002c2:	e04a                	sd	s2,0(sp)
    800002c4:	1000                	add	s0,sp,32
    800002c6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c8:	00011517          	auipc	a0,0x11
    800002cc:	9e850513          	add	a0,a0,-1560 # 80010cb0 <cons>
    800002d0:	00001097          	auipc	ra,0x1
    800002d4:	902080e7          	jalr	-1790(ra) # 80000bd2 <acquire>

  switch(c){
    800002d8:	47d5                	li	a5,21
    800002da:	0af48663          	beq	s1,a5,80000386 <consoleintr+0xcc>
    800002de:	0297ca63          	blt	a5,s1,80000312 <consoleintr+0x58>
    800002e2:	47a1                	li	a5,8
    800002e4:	0ef48763          	beq	s1,a5,800003d2 <consoleintr+0x118>
    800002e8:	47c1                	li	a5,16
    800002ea:	10f49a63          	bne	s1,a5,800003fe <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002ee:	00002097          	auipc	ra,0x2
    800002f2:	47e080e7          	jalr	1150(ra) # 8000276c <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f6:	00011517          	auipc	a0,0x11
    800002fa:	9ba50513          	add	a0,a0,-1606 # 80010cb0 <cons>
    800002fe:	00001097          	auipc	ra,0x1
    80000302:	988080e7          	jalr	-1656(ra) # 80000c86 <release>
}
    80000306:	60e2                	ld	ra,24(sp)
    80000308:	6442                	ld	s0,16(sp)
    8000030a:	64a2                	ld	s1,8(sp)
    8000030c:	6902                	ld	s2,0(sp)
    8000030e:	6105                	add	sp,sp,32
    80000310:	8082                	ret
  switch(c){
    80000312:	07f00793          	li	a5,127
    80000316:	0af48e63          	beq	s1,a5,800003d2 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031a:	00011717          	auipc	a4,0x11
    8000031e:	99670713          	add	a4,a4,-1642 # 80010cb0 <cons>
    80000322:	0a072783          	lw	a5,160(a4)
    80000326:	09872703          	lw	a4,152(a4)
    8000032a:	9f99                	subw	a5,a5,a4
    8000032c:	07f00713          	li	a4,127
    80000330:	fcf763e3          	bltu	a4,a5,800002f6 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000334:	47b5                	li	a5,13
    80000336:	0cf48763          	beq	s1,a5,80000404 <consoleintr+0x14a>
      consputc(c);
    8000033a:	8526                	mv	a0,s1
    8000033c:	00000097          	auipc	ra,0x0
    80000340:	f3c080e7          	jalr	-196(ra) # 80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000344:	00011797          	auipc	a5,0x11
    80000348:	96c78793          	add	a5,a5,-1684 # 80010cb0 <cons>
    8000034c:	0a07a683          	lw	a3,160(a5)
    80000350:	0016871b          	addw	a4,a3,1
    80000354:	0007061b          	sext.w	a2,a4
    80000358:	0ae7a023          	sw	a4,160(a5)
    8000035c:	07f6f693          	and	a3,a3,127
    80000360:	97b6                	add	a5,a5,a3
    80000362:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000366:	47a9                	li	a5,10
    80000368:	0cf48563          	beq	s1,a5,80000432 <consoleintr+0x178>
    8000036c:	4791                	li	a5,4
    8000036e:	0cf48263          	beq	s1,a5,80000432 <consoleintr+0x178>
    80000372:	00011797          	auipc	a5,0x11
    80000376:	9d67a783          	lw	a5,-1578(a5) # 80010d48 <cons+0x98>
    8000037a:	9f1d                	subw	a4,a4,a5
    8000037c:	08000793          	li	a5,128
    80000380:	f6f71be3          	bne	a4,a5,800002f6 <consoleintr+0x3c>
    80000384:	a07d                	j	80000432 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000386:	00011717          	auipc	a4,0x11
    8000038a:	92a70713          	add	a4,a4,-1750 # 80010cb0 <cons>
    8000038e:	0a072783          	lw	a5,160(a4)
    80000392:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000396:	00011497          	auipc	s1,0x11
    8000039a:	91a48493          	add	s1,s1,-1766 # 80010cb0 <cons>
    while(cons.e != cons.w &&
    8000039e:	4929                	li	s2,10
    800003a0:	f4f70be3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a4:	37fd                	addw	a5,a5,-1
    800003a6:	07f7f713          	and	a4,a5,127
    800003aa:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003ac:	01874703          	lbu	a4,24(a4)
    800003b0:	f52703e3          	beq	a4,s2,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003b4:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003b8:	10000513          	li	a0,256
    800003bc:	00000097          	auipc	ra,0x0
    800003c0:	ebc080e7          	jalr	-324(ra) # 80000278 <consputc>
    while(cons.e != cons.w &&
    800003c4:	0a04a783          	lw	a5,160(s1)
    800003c8:	09c4a703          	lw	a4,156(s1)
    800003cc:	fcf71ce3          	bne	a4,a5,800003a4 <consoleintr+0xea>
    800003d0:	b71d                	j	800002f6 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d2:	00011717          	auipc	a4,0x11
    800003d6:	8de70713          	add	a4,a4,-1826 # 80010cb0 <cons>
    800003da:	0a072783          	lw	a5,160(a4)
    800003de:	09c72703          	lw	a4,156(a4)
    800003e2:	f0f70ae3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003e6:	37fd                	addw	a5,a5,-1
    800003e8:	00011717          	auipc	a4,0x11
    800003ec:	96f72423          	sw	a5,-1688(a4) # 80010d50 <cons+0xa0>
      consputc(BACKSPACE);
    800003f0:	10000513          	li	a0,256
    800003f4:	00000097          	auipc	ra,0x0
    800003f8:	e84080e7          	jalr	-380(ra) # 80000278 <consputc>
    800003fc:	bded                	j	800002f6 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003fe:	ee048ce3          	beqz	s1,800002f6 <consoleintr+0x3c>
    80000402:	bf21                	j	8000031a <consoleintr+0x60>
      consputc(c);
    80000404:	4529                	li	a0,10
    80000406:	00000097          	auipc	ra,0x0
    8000040a:	e72080e7          	jalr	-398(ra) # 80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000040e:	00011797          	auipc	a5,0x11
    80000412:	8a278793          	add	a5,a5,-1886 # 80010cb0 <cons>
    80000416:	0a07a703          	lw	a4,160(a5)
    8000041a:	0017069b          	addw	a3,a4,1
    8000041e:	0006861b          	sext.w	a2,a3
    80000422:	0ad7a023          	sw	a3,160(a5)
    80000426:	07f77713          	and	a4,a4,127
    8000042a:	97ba                	add	a5,a5,a4
    8000042c:	4729                	li	a4,10
    8000042e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000432:	00011797          	auipc	a5,0x11
    80000436:	90c7ad23          	sw	a2,-1766(a5) # 80010d4c <cons+0x9c>
        wakeup(&cons.r);
    8000043a:	00011517          	auipc	a0,0x11
    8000043e:	90e50513          	add	a0,a0,-1778 # 80010d48 <cons+0x98>
    80000442:	00002097          	auipc	ra,0x2
    80000446:	ece080e7          	jalr	-306(ra) # 80002310 <wakeup>
    8000044a:	b575                	j	800002f6 <consoleintr+0x3c>

000000008000044c <consoleinit>:

void
consoleinit(void)
{
    8000044c:	1141                	add	sp,sp,-16
    8000044e:	e406                	sd	ra,8(sp)
    80000450:	e022                	sd	s0,0(sp)
    80000452:	0800                	add	s0,sp,16
  initlock(&cons.lock, "cons");
    80000454:	00008597          	auipc	a1,0x8
    80000458:	bbc58593          	add	a1,a1,-1092 # 80008010 <etext+0x10>
    8000045c:	00011517          	auipc	a0,0x11
    80000460:	85450513          	add	a0,a0,-1964 # 80010cb0 <cons>
    80000464:	00000097          	auipc	ra,0x0
    80000468:	6de080e7          	jalr	1758(ra) # 80000b42 <initlock>

  uartinit();
    8000046c:	00000097          	auipc	ra,0x0
    80000470:	32c080e7          	jalr	812(ra) # 80000798 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000474:	00021797          	auipc	a5,0x21
    80000478:	1d478793          	add	a5,a5,468 # 80021648 <devsw>
    8000047c:	00000717          	auipc	a4,0x0
    80000480:	ce870713          	add	a4,a4,-792 # 80000164 <consoleread>
    80000484:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000486:	00000717          	auipc	a4,0x0
    8000048a:	c7a70713          	add	a4,a4,-902 # 80000100 <consolewrite>
    8000048e:	ef98                	sd	a4,24(a5)
}
    80000490:	60a2                	ld	ra,8(sp)
    80000492:	6402                	ld	s0,0(sp)
    80000494:	0141                	add	sp,sp,16
    80000496:	8082                	ret

0000000080000498 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000498:	7179                	add	sp,sp,-48
    8000049a:	f406                	sd	ra,40(sp)
    8000049c:	f022                	sd	s0,32(sp)
    8000049e:	ec26                	sd	s1,24(sp)
    800004a0:	e84a                	sd	s2,16(sp)
    800004a2:	1800                	add	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a4:	c219                	beqz	a2,800004aa <printint+0x12>
    800004a6:	08054763          	bltz	a0,80000534 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004aa:	2501                	sext.w	a0,a0
    800004ac:	4881                	li	a7,0
    800004ae:	fd040693          	add	a3,s0,-48

  i = 0;
    800004b2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b4:	2581                	sext.w	a1,a1
    800004b6:	00008617          	auipc	a2,0x8
    800004ba:	b8a60613          	add	a2,a2,-1142 # 80008040 <digits>
    800004be:	883a                	mv	a6,a4
    800004c0:	2705                	addw	a4,a4,1
    800004c2:	02b577bb          	remuw	a5,a0,a1
    800004c6:	1782                	sll	a5,a5,0x20
    800004c8:	9381                	srl	a5,a5,0x20
    800004ca:	97b2                	add	a5,a5,a2
    800004cc:	0007c783          	lbu	a5,0(a5)
    800004d0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d4:	0005079b          	sext.w	a5,a0
    800004d8:	02b5553b          	divuw	a0,a0,a1
    800004dc:	0685                	add	a3,a3,1
    800004de:	feb7f0e3          	bgeu	a5,a1,800004be <printint+0x26>

  if(sign)
    800004e2:	00088c63          	beqz	a7,800004fa <printint+0x62>
    buf[i++] = '-';
    800004e6:	fe070793          	add	a5,a4,-32
    800004ea:	00878733          	add	a4,a5,s0
    800004ee:	02d00793          	li	a5,45
    800004f2:	fef70823          	sb	a5,-16(a4)
    800004f6:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
    800004fa:	02e05763          	blez	a4,80000528 <printint+0x90>
    800004fe:	fd040793          	add	a5,s0,-48
    80000502:	00e784b3          	add	s1,a5,a4
    80000506:	fff78913          	add	s2,a5,-1
    8000050a:	993a                	add	s2,s2,a4
    8000050c:	377d                	addw	a4,a4,-1
    8000050e:	1702                	sll	a4,a4,0x20
    80000510:	9301                	srl	a4,a4,0x20
    80000512:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000516:	fff4c503          	lbu	a0,-1(s1)
    8000051a:	00000097          	auipc	ra,0x0
    8000051e:	d5e080e7          	jalr	-674(ra) # 80000278 <consputc>
  while(--i >= 0)
    80000522:	14fd                	add	s1,s1,-1
    80000524:	ff2499e3          	bne	s1,s2,80000516 <printint+0x7e>
}
    80000528:	70a2                	ld	ra,40(sp)
    8000052a:	7402                	ld	s0,32(sp)
    8000052c:	64e2                	ld	s1,24(sp)
    8000052e:	6942                	ld	s2,16(sp)
    80000530:	6145                	add	sp,sp,48
    80000532:	8082                	ret
    x = -xx;
    80000534:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000538:	4885                	li	a7,1
    x = -xx;
    8000053a:	bf95                	j	800004ae <printint+0x16>

000000008000053c <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053c:	1101                	add	sp,sp,-32
    8000053e:	ec06                	sd	ra,24(sp)
    80000540:	e822                	sd	s0,16(sp)
    80000542:	e426                	sd	s1,8(sp)
    80000544:	1000                	add	s0,sp,32
    80000546:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000548:	00011797          	auipc	a5,0x11
    8000054c:	8207a423          	sw	zero,-2008(a5) # 80010d70 <pr+0x18>
  printf("panic: ");
    80000550:	00008517          	auipc	a0,0x8
    80000554:	ac850513          	add	a0,a0,-1336 # 80008018 <etext+0x18>
    80000558:	00000097          	auipc	ra,0x0
    8000055c:	02e080e7          	jalr	46(ra) # 80000586 <printf>
  printf(s);
    80000560:	8526                	mv	a0,s1
    80000562:	00000097          	auipc	ra,0x0
    80000566:	024080e7          	jalr	36(ra) # 80000586 <printf>
  printf("\n");
    8000056a:	00008517          	auipc	a0,0x8
    8000056e:	b5e50513          	add	a0,a0,-1186 # 800080c8 <digits+0x88>
    80000572:	00000097          	auipc	ra,0x0
    80000576:	014080e7          	jalr	20(ra) # 80000586 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057a:	4785                	li	a5,1
    8000057c:	00008717          	auipc	a4,0x8
    80000580:	5af72a23          	sw	a5,1460(a4) # 80008b30 <panicked>
  for(;;)
    80000584:	a001                	j	80000584 <panic+0x48>

0000000080000586 <printf>:
{
    80000586:	7131                	add	sp,sp,-192
    80000588:	fc86                	sd	ra,120(sp)
    8000058a:	f8a2                	sd	s0,112(sp)
    8000058c:	f4a6                	sd	s1,104(sp)
    8000058e:	f0ca                	sd	s2,96(sp)
    80000590:	ecce                	sd	s3,88(sp)
    80000592:	e8d2                	sd	s4,80(sp)
    80000594:	e4d6                	sd	s5,72(sp)
    80000596:	e0da                	sd	s6,64(sp)
    80000598:	fc5e                	sd	s7,56(sp)
    8000059a:	f862                	sd	s8,48(sp)
    8000059c:	f466                	sd	s9,40(sp)
    8000059e:	f06a                	sd	s10,32(sp)
    800005a0:	ec6e                	sd	s11,24(sp)
    800005a2:	0100                	add	s0,sp,128
    800005a4:	8a2a                	mv	s4,a0
    800005a6:	e40c                	sd	a1,8(s0)
    800005a8:	e810                	sd	a2,16(s0)
    800005aa:	ec14                	sd	a3,24(s0)
    800005ac:	f018                	sd	a4,32(s0)
    800005ae:	f41c                	sd	a5,40(s0)
    800005b0:	03043823          	sd	a6,48(s0)
    800005b4:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005b8:	00010d97          	auipc	s11,0x10
    800005bc:	7b8dad83          	lw	s11,1976(s11) # 80010d70 <pr+0x18>
  if(locking)
    800005c0:	020d9b63          	bnez	s11,800005f6 <printf+0x70>
  if (fmt == 0)
    800005c4:	040a0263          	beqz	s4,80000608 <printf+0x82>
  va_start(ap, fmt);
    800005c8:	00840793          	add	a5,s0,8
    800005cc:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d0:	000a4503          	lbu	a0,0(s4)
    800005d4:	14050f63          	beqz	a0,80000732 <printf+0x1ac>
    800005d8:	4981                	li	s3,0
    if(c != '%'){
    800005da:	02500a93          	li	s5,37
    switch(c){
    800005de:	07000b93          	li	s7,112
  consputc('x');
    800005e2:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e4:	00008b17          	auipc	s6,0x8
    800005e8:	a5cb0b13          	add	s6,s6,-1444 # 80008040 <digits>
    switch(c){
    800005ec:	07300c93          	li	s9,115
    800005f0:	06400c13          	li	s8,100
    800005f4:	a82d                	j	8000062e <printf+0xa8>
    acquire(&pr.lock);
    800005f6:	00010517          	auipc	a0,0x10
    800005fa:	76250513          	add	a0,a0,1890 # 80010d58 <pr>
    800005fe:	00000097          	auipc	ra,0x0
    80000602:	5d4080e7          	jalr	1492(ra) # 80000bd2 <acquire>
    80000606:	bf7d                	j	800005c4 <printf+0x3e>
    panic("null fmt");
    80000608:	00008517          	auipc	a0,0x8
    8000060c:	a2050513          	add	a0,a0,-1504 # 80008028 <etext+0x28>
    80000610:	00000097          	auipc	ra,0x0
    80000614:	f2c080e7          	jalr	-212(ra) # 8000053c <panic>
      consputc(c);
    80000618:	00000097          	auipc	ra,0x0
    8000061c:	c60080e7          	jalr	-928(ra) # 80000278 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000620:	2985                	addw	s3,s3,1
    80000622:	013a07b3          	add	a5,s4,s3
    80000626:	0007c503          	lbu	a0,0(a5)
    8000062a:	10050463          	beqz	a0,80000732 <printf+0x1ac>
    if(c != '%'){
    8000062e:	ff5515e3          	bne	a0,s5,80000618 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000632:	2985                	addw	s3,s3,1
    80000634:	013a07b3          	add	a5,s4,s3
    80000638:	0007c783          	lbu	a5,0(a5)
    8000063c:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000640:	cbed                	beqz	a5,80000732 <printf+0x1ac>
    switch(c){
    80000642:	05778a63          	beq	a5,s7,80000696 <printf+0x110>
    80000646:	02fbf663          	bgeu	s7,a5,80000672 <printf+0xec>
    8000064a:	09978863          	beq	a5,s9,800006da <printf+0x154>
    8000064e:	07800713          	li	a4,120
    80000652:	0ce79563          	bne	a5,a4,8000071c <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000656:	f8843783          	ld	a5,-120(s0)
    8000065a:	00878713          	add	a4,a5,8
    8000065e:	f8e43423          	sd	a4,-120(s0)
    80000662:	4605                	li	a2,1
    80000664:	85ea                	mv	a1,s10
    80000666:	4388                	lw	a0,0(a5)
    80000668:	00000097          	auipc	ra,0x0
    8000066c:	e30080e7          	jalr	-464(ra) # 80000498 <printint>
      break;
    80000670:	bf45                	j	80000620 <printf+0x9a>
    switch(c){
    80000672:	09578f63          	beq	a5,s5,80000710 <printf+0x18a>
    80000676:	0b879363          	bne	a5,s8,8000071c <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067a:	f8843783          	ld	a5,-120(s0)
    8000067e:	00878713          	add	a4,a5,8
    80000682:	f8e43423          	sd	a4,-120(s0)
    80000686:	4605                	li	a2,1
    80000688:	45a9                	li	a1,10
    8000068a:	4388                	lw	a0,0(a5)
    8000068c:	00000097          	auipc	ra,0x0
    80000690:	e0c080e7          	jalr	-500(ra) # 80000498 <printint>
      break;
    80000694:	b771                	j	80000620 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	add	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a6:	03000513          	li	a0,48
    800006aa:	00000097          	auipc	ra,0x0
    800006ae:	bce080e7          	jalr	-1074(ra) # 80000278 <consputc>
  consputc('x');
    800006b2:	07800513          	li	a0,120
    800006b6:	00000097          	auipc	ra,0x0
    800006ba:	bc2080e7          	jalr	-1086(ra) # 80000278 <consputc>
    800006be:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c0:	03c95793          	srl	a5,s2,0x3c
    800006c4:	97da                	add	a5,a5,s6
    800006c6:	0007c503          	lbu	a0,0(a5)
    800006ca:	00000097          	auipc	ra,0x0
    800006ce:	bae080e7          	jalr	-1106(ra) # 80000278 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d2:	0912                	sll	s2,s2,0x4
    800006d4:	34fd                	addw	s1,s1,-1
    800006d6:	f4ed                	bnez	s1,800006c0 <printf+0x13a>
    800006d8:	b7a1                	j	80000620 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006da:	f8843783          	ld	a5,-120(s0)
    800006de:	00878713          	add	a4,a5,8
    800006e2:	f8e43423          	sd	a4,-120(s0)
    800006e6:	6384                	ld	s1,0(a5)
    800006e8:	cc89                	beqz	s1,80000702 <printf+0x17c>
      for(; *s; s++)
    800006ea:	0004c503          	lbu	a0,0(s1)
    800006ee:	d90d                	beqz	a0,80000620 <printf+0x9a>
        consputc(*s);
    800006f0:	00000097          	auipc	ra,0x0
    800006f4:	b88080e7          	jalr	-1144(ra) # 80000278 <consputc>
      for(; *s; s++)
    800006f8:	0485                	add	s1,s1,1
    800006fa:	0004c503          	lbu	a0,0(s1)
    800006fe:	f96d                	bnez	a0,800006f0 <printf+0x16a>
    80000700:	b705                	j	80000620 <printf+0x9a>
        s = "(null)";
    80000702:	00008497          	auipc	s1,0x8
    80000706:	91e48493          	add	s1,s1,-1762 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070a:	02800513          	li	a0,40
    8000070e:	b7cd                	j	800006f0 <printf+0x16a>
      consputc('%');
    80000710:	8556                	mv	a0,s5
    80000712:	00000097          	auipc	ra,0x0
    80000716:	b66080e7          	jalr	-1178(ra) # 80000278 <consputc>
      break;
    8000071a:	b719                	j	80000620 <printf+0x9a>
      consputc('%');
    8000071c:	8556                	mv	a0,s5
    8000071e:	00000097          	auipc	ra,0x0
    80000722:	b5a080e7          	jalr	-1190(ra) # 80000278 <consputc>
      consputc(c);
    80000726:	8526                	mv	a0,s1
    80000728:	00000097          	auipc	ra,0x0
    8000072c:	b50080e7          	jalr	-1200(ra) # 80000278 <consputc>
      break;
    80000730:	bdc5                	j	80000620 <printf+0x9a>
  if(locking)
    80000732:	020d9163          	bnez	s11,80000754 <printf+0x1ce>
}
    80000736:	70e6                	ld	ra,120(sp)
    80000738:	7446                	ld	s0,112(sp)
    8000073a:	74a6                	ld	s1,104(sp)
    8000073c:	7906                	ld	s2,96(sp)
    8000073e:	69e6                	ld	s3,88(sp)
    80000740:	6a46                	ld	s4,80(sp)
    80000742:	6aa6                	ld	s5,72(sp)
    80000744:	6b06                	ld	s6,64(sp)
    80000746:	7be2                	ld	s7,56(sp)
    80000748:	7c42                	ld	s8,48(sp)
    8000074a:	7ca2                	ld	s9,40(sp)
    8000074c:	7d02                	ld	s10,32(sp)
    8000074e:	6de2                	ld	s11,24(sp)
    80000750:	6129                	add	sp,sp,192
    80000752:	8082                	ret
    release(&pr.lock);
    80000754:	00010517          	auipc	a0,0x10
    80000758:	60450513          	add	a0,a0,1540 # 80010d58 <pr>
    8000075c:	00000097          	auipc	ra,0x0
    80000760:	52a080e7          	jalr	1322(ra) # 80000c86 <release>
}
    80000764:	bfc9                	j	80000736 <printf+0x1b0>

0000000080000766 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000766:	1101                	add	sp,sp,-32
    80000768:	ec06                	sd	ra,24(sp)
    8000076a:	e822                	sd	s0,16(sp)
    8000076c:	e426                	sd	s1,8(sp)
    8000076e:	1000                	add	s0,sp,32
  initlock(&pr.lock, "pr");
    80000770:	00010497          	auipc	s1,0x10
    80000774:	5e848493          	add	s1,s1,1512 # 80010d58 <pr>
    80000778:	00008597          	auipc	a1,0x8
    8000077c:	8c058593          	add	a1,a1,-1856 # 80008038 <etext+0x38>
    80000780:	8526                	mv	a0,s1
    80000782:	00000097          	auipc	ra,0x0
    80000786:	3c0080e7          	jalr	960(ra) # 80000b42 <initlock>
  pr.locking = 1;
    8000078a:	4785                	li	a5,1
    8000078c:	cc9c                	sw	a5,24(s1)
}
    8000078e:	60e2                	ld	ra,24(sp)
    80000790:	6442                	ld	s0,16(sp)
    80000792:	64a2                	ld	s1,8(sp)
    80000794:	6105                	add	sp,sp,32
    80000796:	8082                	ret

0000000080000798 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000798:	1141                	add	sp,sp,-16
    8000079a:	e406                	sd	ra,8(sp)
    8000079c:	e022                	sd	s0,0(sp)
    8000079e:	0800                	add	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a0:	100007b7          	lui	a5,0x10000
    800007a4:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007a8:	f8000713          	li	a4,-128
    800007ac:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b0:	470d                	li	a4,3
    800007b2:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b6:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007ba:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007be:	469d                	li	a3,7
    800007c0:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c4:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007c8:	00008597          	auipc	a1,0x8
    800007cc:	89058593          	add	a1,a1,-1904 # 80008058 <digits+0x18>
    800007d0:	00010517          	auipc	a0,0x10
    800007d4:	5a850513          	add	a0,a0,1448 # 80010d78 <uart_tx_lock>
    800007d8:	00000097          	auipc	ra,0x0
    800007dc:	36a080e7          	jalr	874(ra) # 80000b42 <initlock>
}
    800007e0:	60a2                	ld	ra,8(sp)
    800007e2:	6402                	ld	s0,0(sp)
    800007e4:	0141                	add	sp,sp,16
    800007e6:	8082                	ret

00000000800007e8 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007e8:	1101                	add	sp,sp,-32
    800007ea:	ec06                	sd	ra,24(sp)
    800007ec:	e822                	sd	s0,16(sp)
    800007ee:	e426                	sd	s1,8(sp)
    800007f0:	1000                	add	s0,sp,32
    800007f2:	84aa                	mv	s1,a0
  push_off();
    800007f4:	00000097          	auipc	ra,0x0
    800007f8:	392080e7          	jalr	914(ra) # 80000b86 <push_off>

  if(panicked){
    800007fc:	00008797          	auipc	a5,0x8
    80000800:	3347a783          	lw	a5,820(a5) # 80008b30 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000804:	10000737          	lui	a4,0x10000
  if(panicked){
    80000808:	c391                	beqz	a5,8000080c <uartputc_sync+0x24>
    for(;;)
    8000080a:	a001                	j	8000080a <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080c:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000810:	0207f793          	and	a5,a5,32
    80000814:	dfe5                	beqz	a5,8000080c <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000816:	0ff4f513          	zext.b	a0,s1
    8000081a:	100007b7          	lui	a5,0x10000
    8000081e:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000822:	00000097          	auipc	ra,0x0
    80000826:	404080e7          	jalr	1028(ra) # 80000c26 <pop_off>
}
    8000082a:	60e2                	ld	ra,24(sp)
    8000082c:	6442                	ld	s0,16(sp)
    8000082e:	64a2                	ld	s1,8(sp)
    80000830:	6105                	add	sp,sp,32
    80000832:	8082                	ret

0000000080000834 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000834:	00008797          	auipc	a5,0x8
    80000838:	3047b783          	ld	a5,772(a5) # 80008b38 <uart_tx_r>
    8000083c:	00008717          	auipc	a4,0x8
    80000840:	30473703          	ld	a4,772(a4) # 80008b40 <uart_tx_w>
    80000844:	06f70a63          	beq	a4,a5,800008b8 <uartstart+0x84>
{
    80000848:	7139                	add	sp,sp,-64
    8000084a:	fc06                	sd	ra,56(sp)
    8000084c:	f822                	sd	s0,48(sp)
    8000084e:	f426                	sd	s1,40(sp)
    80000850:	f04a                	sd	s2,32(sp)
    80000852:	ec4e                	sd	s3,24(sp)
    80000854:	e852                	sd	s4,16(sp)
    80000856:	e456                	sd	s5,8(sp)
    80000858:	0080                	add	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085a:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000085e:	00010a17          	auipc	s4,0x10
    80000862:	51aa0a13          	add	s4,s4,1306 # 80010d78 <uart_tx_lock>
    uart_tx_r += 1;
    80000866:	00008497          	auipc	s1,0x8
    8000086a:	2d248493          	add	s1,s1,722 # 80008b38 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086e:	00008997          	auipc	s3,0x8
    80000872:	2d298993          	add	s3,s3,722 # 80008b40 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000876:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087a:	02077713          	and	a4,a4,32
    8000087e:	c705                	beqz	a4,800008a6 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000880:	01f7f713          	and	a4,a5,31
    80000884:	9752                	add	a4,a4,s4
    80000886:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088a:	0785                	add	a5,a5,1
    8000088c:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000088e:	8526                	mv	a0,s1
    80000890:	00002097          	auipc	ra,0x2
    80000894:	a80080e7          	jalr	-1408(ra) # 80002310 <wakeup>
    
    WriteReg(THR, c);
    80000898:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089c:	609c                	ld	a5,0(s1)
    8000089e:	0009b703          	ld	a4,0(s3)
    800008a2:	fcf71ae3          	bne	a4,a5,80000876 <uartstart+0x42>
  }
}
    800008a6:	70e2                	ld	ra,56(sp)
    800008a8:	7442                	ld	s0,48(sp)
    800008aa:	74a2                	ld	s1,40(sp)
    800008ac:	7902                	ld	s2,32(sp)
    800008ae:	69e2                	ld	s3,24(sp)
    800008b0:	6a42                	ld	s4,16(sp)
    800008b2:	6aa2                	ld	s5,8(sp)
    800008b4:	6121                	add	sp,sp,64
    800008b6:	8082                	ret
    800008b8:	8082                	ret

00000000800008ba <uartputc>:
{
    800008ba:	7179                	add	sp,sp,-48
    800008bc:	f406                	sd	ra,40(sp)
    800008be:	f022                	sd	s0,32(sp)
    800008c0:	ec26                	sd	s1,24(sp)
    800008c2:	e84a                	sd	s2,16(sp)
    800008c4:	e44e                	sd	s3,8(sp)
    800008c6:	e052                	sd	s4,0(sp)
    800008c8:	1800                	add	s0,sp,48
    800008ca:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008cc:	00010517          	auipc	a0,0x10
    800008d0:	4ac50513          	add	a0,a0,1196 # 80010d78 <uart_tx_lock>
    800008d4:	00000097          	auipc	ra,0x0
    800008d8:	2fe080e7          	jalr	766(ra) # 80000bd2 <acquire>
  if(panicked){
    800008dc:	00008797          	auipc	a5,0x8
    800008e0:	2547a783          	lw	a5,596(a5) # 80008b30 <panicked>
    800008e4:	e7c9                	bnez	a5,8000096e <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e6:	00008717          	auipc	a4,0x8
    800008ea:	25a73703          	ld	a4,602(a4) # 80008b40 <uart_tx_w>
    800008ee:	00008797          	auipc	a5,0x8
    800008f2:	24a7b783          	ld	a5,586(a5) # 80008b38 <uart_tx_r>
    800008f6:	02078793          	add	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fa:	00010997          	auipc	s3,0x10
    800008fe:	47e98993          	add	s3,s3,1150 # 80010d78 <uart_tx_lock>
    80000902:	00008497          	auipc	s1,0x8
    80000906:	23648493          	add	s1,s1,566 # 80008b38 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090a:	00008917          	auipc	s2,0x8
    8000090e:	23690913          	add	s2,s2,566 # 80008b40 <uart_tx_w>
    80000912:	00e79f63          	bne	a5,a4,80000930 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000916:	85ce                	mv	a1,s3
    80000918:	8526                	mv	a0,s1
    8000091a:	00002097          	auipc	ra,0x2
    8000091e:	846080e7          	jalr	-1978(ra) # 80002160 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000922:	00093703          	ld	a4,0(s2)
    80000926:	609c                	ld	a5,0(s1)
    80000928:	02078793          	add	a5,a5,32
    8000092c:	fee785e3          	beq	a5,a4,80000916 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000930:	00010497          	auipc	s1,0x10
    80000934:	44848493          	add	s1,s1,1096 # 80010d78 <uart_tx_lock>
    80000938:	01f77793          	and	a5,a4,31
    8000093c:	97a6                	add	a5,a5,s1
    8000093e:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000942:	0705                	add	a4,a4,1
    80000944:	00008797          	auipc	a5,0x8
    80000948:	1ee7be23          	sd	a4,508(a5) # 80008b40 <uart_tx_w>
  uartstart();
    8000094c:	00000097          	auipc	ra,0x0
    80000950:	ee8080e7          	jalr	-280(ra) # 80000834 <uartstart>
  release(&uart_tx_lock);
    80000954:	8526                	mv	a0,s1
    80000956:	00000097          	auipc	ra,0x0
    8000095a:	330080e7          	jalr	816(ra) # 80000c86 <release>
}
    8000095e:	70a2                	ld	ra,40(sp)
    80000960:	7402                	ld	s0,32(sp)
    80000962:	64e2                	ld	s1,24(sp)
    80000964:	6942                	ld	s2,16(sp)
    80000966:	69a2                	ld	s3,8(sp)
    80000968:	6a02                	ld	s4,0(sp)
    8000096a:	6145                	add	sp,sp,48
    8000096c:	8082                	ret
    for(;;)
    8000096e:	a001                	j	8000096e <uartputc+0xb4>

0000000080000970 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000970:	1141                	add	sp,sp,-16
    80000972:	e422                	sd	s0,8(sp)
    80000974:	0800                	add	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000976:	100007b7          	lui	a5,0x10000
    8000097a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000097e:	8b85                	and	a5,a5,1
    80000980:	cb81                	beqz	a5,80000990 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000982:	100007b7          	lui	a5,0x10000
    80000986:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000098a:	6422                	ld	s0,8(sp)
    8000098c:	0141                	add	sp,sp,16
    8000098e:	8082                	ret
    return -1;
    80000990:	557d                	li	a0,-1
    80000992:	bfe5                	j	8000098a <uartgetc+0x1a>

0000000080000994 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000994:	1101                	add	sp,sp,-32
    80000996:	ec06                	sd	ra,24(sp)
    80000998:	e822                	sd	s0,16(sp)
    8000099a:	e426                	sd	s1,8(sp)
    8000099c:	1000                	add	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000099e:	54fd                	li	s1,-1
    800009a0:	a029                	j	800009aa <uartintr+0x16>
      break;
    consoleintr(c);
    800009a2:	00000097          	auipc	ra,0x0
    800009a6:	918080e7          	jalr	-1768(ra) # 800002ba <consoleintr>
    int c = uartgetc();
    800009aa:	00000097          	auipc	ra,0x0
    800009ae:	fc6080e7          	jalr	-58(ra) # 80000970 <uartgetc>
    if(c == -1)
    800009b2:	fe9518e3          	bne	a0,s1,800009a2 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009b6:	00010497          	auipc	s1,0x10
    800009ba:	3c248493          	add	s1,s1,962 # 80010d78 <uart_tx_lock>
    800009be:	8526                	mv	a0,s1
    800009c0:	00000097          	auipc	ra,0x0
    800009c4:	212080e7          	jalr	530(ra) # 80000bd2 <acquire>
  uartstart();
    800009c8:	00000097          	auipc	ra,0x0
    800009cc:	e6c080e7          	jalr	-404(ra) # 80000834 <uartstart>
  release(&uart_tx_lock);
    800009d0:	8526                	mv	a0,s1
    800009d2:	00000097          	auipc	ra,0x0
    800009d6:	2b4080e7          	jalr	692(ra) # 80000c86 <release>
}
    800009da:	60e2                	ld	ra,24(sp)
    800009dc:	6442                	ld	s0,16(sp)
    800009de:	64a2                	ld	s1,8(sp)
    800009e0:	6105                	add	sp,sp,32
    800009e2:	8082                	ret

00000000800009e4 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e4:	1101                	add	sp,sp,-32
    800009e6:	ec06                	sd	ra,24(sp)
    800009e8:	e822                	sd	s0,16(sp)
    800009ea:	e426                	sd	s1,8(sp)
    800009ec:	e04a                	sd	s2,0(sp)
    800009ee:	1000                	add	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f0:	03451793          	sll	a5,a0,0x34
    800009f4:	ebb9                	bnez	a5,80000a4a <kfree+0x66>
    800009f6:	84aa                	mv	s1,a0
    800009f8:	00022797          	auipc	a5,0x22
    800009fc:	de878793          	add	a5,a5,-536 # 800227e0 <end>
    80000a00:	04f56563          	bltu	a0,a5,80000a4a <kfree+0x66>
    80000a04:	47c5                	li	a5,17
    80000a06:	07ee                	sll	a5,a5,0x1b
    80000a08:	04f57163          	bgeu	a0,a5,80000a4a <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a0c:	6605                	lui	a2,0x1
    80000a0e:	4585                	li	a1,1
    80000a10:	00000097          	auipc	ra,0x0
    80000a14:	2be080e7          	jalr	702(ra) # 80000cce <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a18:	00010917          	auipc	s2,0x10
    80000a1c:	39890913          	add	s2,s2,920 # 80010db0 <kmem>
    80000a20:	854a                	mv	a0,s2
    80000a22:	00000097          	auipc	ra,0x0
    80000a26:	1b0080e7          	jalr	432(ra) # 80000bd2 <acquire>
  r->next = kmem.freelist;
    80000a2a:	01893783          	ld	a5,24(s2)
    80000a2e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a30:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a34:	854a                	mv	a0,s2
    80000a36:	00000097          	auipc	ra,0x0
    80000a3a:	250080e7          	jalr	592(ra) # 80000c86 <release>
}
    80000a3e:	60e2                	ld	ra,24(sp)
    80000a40:	6442                	ld	s0,16(sp)
    80000a42:	64a2                	ld	s1,8(sp)
    80000a44:	6902                	ld	s2,0(sp)
    80000a46:	6105                	add	sp,sp,32
    80000a48:	8082                	ret
    panic("kfree");
    80000a4a:	00007517          	auipc	a0,0x7
    80000a4e:	61650513          	add	a0,a0,1558 # 80008060 <digits+0x20>
    80000a52:	00000097          	auipc	ra,0x0
    80000a56:	aea080e7          	jalr	-1302(ra) # 8000053c <panic>

0000000080000a5a <freerange>:
{
    80000a5a:	7179                	add	sp,sp,-48
    80000a5c:	f406                	sd	ra,40(sp)
    80000a5e:	f022                	sd	s0,32(sp)
    80000a60:	ec26                	sd	s1,24(sp)
    80000a62:	e84a                	sd	s2,16(sp)
    80000a64:	e44e                	sd	s3,8(sp)
    80000a66:	e052                	sd	s4,0(sp)
    80000a68:	1800                	add	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a6a:	6785                	lui	a5,0x1
    80000a6c:	fff78713          	add	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a70:	00e504b3          	add	s1,a0,a4
    80000a74:	777d                	lui	a4,0xfffff
    80000a76:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a78:	94be                	add	s1,s1,a5
    80000a7a:	0095ee63          	bltu	a1,s1,80000a96 <freerange+0x3c>
    80000a7e:	892e                	mv	s2,a1
    kfree(p);
    80000a80:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a82:	6985                	lui	s3,0x1
    kfree(p);
    80000a84:	01448533          	add	a0,s1,s4
    80000a88:	00000097          	auipc	ra,0x0
    80000a8c:	f5c080e7          	jalr	-164(ra) # 800009e4 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a90:	94ce                	add	s1,s1,s3
    80000a92:	fe9979e3          	bgeu	s2,s1,80000a84 <freerange+0x2a>
}
    80000a96:	70a2                	ld	ra,40(sp)
    80000a98:	7402                	ld	s0,32(sp)
    80000a9a:	64e2                	ld	s1,24(sp)
    80000a9c:	6942                	ld	s2,16(sp)
    80000a9e:	69a2                	ld	s3,8(sp)
    80000aa0:	6a02                	ld	s4,0(sp)
    80000aa2:	6145                	add	sp,sp,48
    80000aa4:	8082                	ret

0000000080000aa6 <kinit>:
{
    80000aa6:	1141                	add	sp,sp,-16
    80000aa8:	e406                	sd	ra,8(sp)
    80000aaa:	e022                	sd	s0,0(sp)
    80000aac:	0800                	add	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000aae:	00007597          	auipc	a1,0x7
    80000ab2:	5ba58593          	add	a1,a1,1466 # 80008068 <digits+0x28>
    80000ab6:	00010517          	auipc	a0,0x10
    80000aba:	2fa50513          	add	a0,a0,762 # 80010db0 <kmem>
    80000abe:	00000097          	auipc	ra,0x0
    80000ac2:	084080e7          	jalr	132(ra) # 80000b42 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac6:	45c5                	li	a1,17
    80000ac8:	05ee                	sll	a1,a1,0x1b
    80000aca:	00022517          	auipc	a0,0x22
    80000ace:	d1650513          	add	a0,a0,-746 # 800227e0 <end>
    80000ad2:	00000097          	auipc	ra,0x0
    80000ad6:	f88080e7          	jalr	-120(ra) # 80000a5a <freerange>
}
    80000ada:	60a2                	ld	ra,8(sp)
    80000adc:	6402                	ld	s0,0(sp)
    80000ade:	0141                	add	sp,sp,16
    80000ae0:	8082                	ret

0000000080000ae2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae2:	1101                	add	sp,sp,-32
    80000ae4:	ec06                	sd	ra,24(sp)
    80000ae6:	e822                	sd	s0,16(sp)
    80000ae8:	e426                	sd	s1,8(sp)
    80000aea:	1000                	add	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000aec:	00010497          	auipc	s1,0x10
    80000af0:	2c448493          	add	s1,s1,708 # 80010db0 <kmem>
    80000af4:	8526                	mv	a0,s1
    80000af6:	00000097          	auipc	ra,0x0
    80000afa:	0dc080e7          	jalr	220(ra) # 80000bd2 <acquire>
  r = kmem.freelist;
    80000afe:	6c84                	ld	s1,24(s1)
  if(r)
    80000b00:	c885                	beqz	s1,80000b30 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b02:	609c                	ld	a5,0(s1)
    80000b04:	00010517          	auipc	a0,0x10
    80000b08:	2ac50513          	add	a0,a0,684 # 80010db0 <kmem>
    80000b0c:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b0e:	00000097          	auipc	ra,0x0
    80000b12:	178080e7          	jalr	376(ra) # 80000c86 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b16:	6605                	lui	a2,0x1
    80000b18:	4595                	li	a1,5
    80000b1a:	8526                	mv	a0,s1
    80000b1c:	00000097          	auipc	ra,0x0
    80000b20:	1b2080e7          	jalr	434(ra) # 80000cce <memset>
  return (void*)r;
}
    80000b24:	8526                	mv	a0,s1
    80000b26:	60e2                	ld	ra,24(sp)
    80000b28:	6442                	ld	s0,16(sp)
    80000b2a:	64a2                	ld	s1,8(sp)
    80000b2c:	6105                	add	sp,sp,32
    80000b2e:	8082                	ret
  release(&kmem.lock);
    80000b30:	00010517          	auipc	a0,0x10
    80000b34:	28050513          	add	a0,a0,640 # 80010db0 <kmem>
    80000b38:	00000097          	auipc	ra,0x0
    80000b3c:	14e080e7          	jalr	334(ra) # 80000c86 <release>
  if(r)
    80000b40:	b7d5                	j	80000b24 <kalloc+0x42>

0000000080000b42 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b42:	1141                	add	sp,sp,-16
    80000b44:	e422                	sd	s0,8(sp)
    80000b46:	0800                	add	s0,sp,16
  lk->name = name;
    80000b48:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b4e:	00053823          	sd	zero,16(a0)
}
    80000b52:	6422                	ld	s0,8(sp)
    80000b54:	0141                	add	sp,sp,16
    80000b56:	8082                	ret

0000000080000b58 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b58:	411c                	lw	a5,0(a0)
    80000b5a:	e399                	bnez	a5,80000b60 <holding+0x8>
    80000b5c:	4501                	li	a0,0
  return r;
}
    80000b5e:	8082                	ret
{
    80000b60:	1101                	add	sp,sp,-32
    80000b62:	ec06                	sd	ra,24(sp)
    80000b64:	e822                	sd	s0,16(sp)
    80000b66:	e426                	sd	s1,8(sp)
    80000b68:	1000                	add	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6a:	6904                	ld	s1,16(a0)
    80000b6c:	00001097          	auipc	ra,0x1
    80000b70:	e1e080e7          	jalr	-482(ra) # 8000198a <mycpu>
    80000b74:	40a48533          	sub	a0,s1,a0
    80000b78:	00153513          	seqz	a0,a0
}
    80000b7c:	60e2                	ld	ra,24(sp)
    80000b7e:	6442                	ld	s0,16(sp)
    80000b80:	64a2                	ld	s1,8(sp)
    80000b82:	6105                	add	sp,sp,32
    80000b84:	8082                	ret

0000000080000b86 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b86:	1101                	add	sp,sp,-32
    80000b88:	ec06                	sd	ra,24(sp)
    80000b8a:	e822                	sd	s0,16(sp)
    80000b8c:	e426                	sd	s1,8(sp)
    80000b8e:	1000                	add	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b90:	100024f3          	csrr	s1,sstatus
    80000b94:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b98:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9a:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b9e:	00001097          	auipc	ra,0x1
    80000ba2:	dec080e7          	jalr	-532(ra) # 8000198a <mycpu>
    80000ba6:	5d3c                	lw	a5,120(a0)
    80000ba8:	cf89                	beqz	a5,80000bc2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000baa:	00001097          	auipc	ra,0x1
    80000bae:	de0080e7          	jalr	-544(ra) # 8000198a <mycpu>
    80000bb2:	5d3c                	lw	a5,120(a0)
    80000bb4:	2785                	addw	a5,a5,1
    80000bb6:	dd3c                	sw	a5,120(a0)
}
    80000bb8:	60e2                	ld	ra,24(sp)
    80000bba:	6442                	ld	s0,16(sp)
    80000bbc:	64a2                	ld	s1,8(sp)
    80000bbe:	6105                	add	sp,sp,32
    80000bc0:	8082                	ret
    mycpu()->intena = old;
    80000bc2:	00001097          	auipc	ra,0x1
    80000bc6:	dc8080e7          	jalr	-568(ra) # 8000198a <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bca:	8085                	srl	s1,s1,0x1
    80000bcc:	8885                	and	s1,s1,1
    80000bce:	dd64                	sw	s1,124(a0)
    80000bd0:	bfe9                	j	80000baa <push_off+0x24>

0000000080000bd2 <acquire>:
{
    80000bd2:	1101                	add	sp,sp,-32
    80000bd4:	ec06                	sd	ra,24(sp)
    80000bd6:	e822                	sd	s0,16(sp)
    80000bd8:	e426                	sd	s1,8(sp)
    80000bda:	1000                	add	s0,sp,32
    80000bdc:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bde:	00000097          	auipc	ra,0x0
    80000be2:	fa8080e7          	jalr	-88(ra) # 80000b86 <push_off>
  if(holding(lk))
    80000be6:	8526                	mv	a0,s1
    80000be8:	00000097          	auipc	ra,0x0
    80000bec:	f70080e7          	jalr	-144(ra) # 80000b58 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf0:	4705                	li	a4,1
  if(holding(lk))
    80000bf2:	e115                	bnez	a0,80000c16 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	87ba                	mv	a5,a4
    80000bf6:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfa:	2781                	sext.w	a5,a5
    80000bfc:	ffe5                	bnez	a5,80000bf4 <acquire+0x22>
  __sync_synchronize();
    80000bfe:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c02:	00001097          	auipc	ra,0x1
    80000c06:	d88080e7          	jalr	-632(ra) # 8000198a <mycpu>
    80000c0a:	e888                	sd	a0,16(s1)
}
    80000c0c:	60e2                	ld	ra,24(sp)
    80000c0e:	6442                	ld	s0,16(sp)
    80000c10:	64a2                	ld	s1,8(sp)
    80000c12:	6105                	add	sp,sp,32
    80000c14:	8082                	ret
    panic("acquire");
    80000c16:	00007517          	auipc	a0,0x7
    80000c1a:	45a50513          	add	a0,a0,1114 # 80008070 <digits+0x30>
    80000c1e:	00000097          	auipc	ra,0x0
    80000c22:	91e080e7          	jalr	-1762(ra) # 8000053c <panic>

0000000080000c26 <pop_off>:

void
pop_off(void)
{
    80000c26:	1141                	add	sp,sp,-16
    80000c28:	e406                	sd	ra,8(sp)
    80000c2a:	e022                	sd	s0,0(sp)
    80000c2c:	0800                	add	s0,sp,16
  struct cpu *c = mycpu();
    80000c2e:	00001097          	auipc	ra,0x1
    80000c32:	d5c080e7          	jalr	-676(ra) # 8000198a <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c36:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3a:	8b89                	and	a5,a5,2
  if(intr_get())
    80000c3c:	e78d                	bnez	a5,80000c66 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c3e:	5d3c                	lw	a5,120(a0)
    80000c40:	02f05b63          	blez	a5,80000c76 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c44:	37fd                	addw	a5,a5,-1
    80000c46:	0007871b          	sext.w	a4,a5
    80000c4a:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c4c:	eb09                	bnez	a4,80000c5e <pop_off+0x38>
    80000c4e:	5d7c                	lw	a5,124(a0)
    80000c50:	c799                	beqz	a5,80000c5e <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c52:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c56:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5a:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c5e:	60a2                	ld	ra,8(sp)
    80000c60:	6402                	ld	s0,0(sp)
    80000c62:	0141                	add	sp,sp,16
    80000c64:	8082                	ret
    panic("pop_off - interruptible");
    80000c66:	00007517          	auipc	a0,0x7
    80000c6a:	41250513          	add	a0,a0,1042 # 80008078 <digits+0x38>
    80000c6e:	00000097          	auipc	ra,0x0
    80000c72:	8ce080e7          	jalr	-1842(ra) # 8000053c <panic>
    panic("pop_off");
    80000c76:	00007517          	auipc	a0,0x7
    80000c7a:	41a50513          	add	a0,a0,1050 # 80008090 <digits+0x50>
    80000c7e:	00000097          	auipc	ra,0x0
    80000c82:	8be080e7          	jalr	-1858(ra) # 8000053c <panic>

0000000080000c86 <release>:
{
    80000c86:	1101                	add	sp,sp,-32
    80000c88:	ec06                	sd	ra,24(sp)
    80000c8a:	e822                	sd	s0,16(sp)
    80000c8c:	e426                	sd	s1,8(sp)
    80000c8e:	1000                	add	s0,sp,32
    80000c90:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c92:	00000097          	auipc	ra,0x0
    80000c96:	ec6080e7          	jalr	-314(ra) # 80000b58 <holding>
    80000c9a:	c115                	beqz	a0,80000cbe <release+0x38>
  lk->cpu = 0;
    80000c9c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca0:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca4:	0f50000f          	fence	iorw,ow
    80000ca8:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cac:	00000097          	auipc	ra,0x0
    80000cb0:	f7a080e7          	jalr	-134(ra) # 80000c26 <pop_off>
}
    80000cb4:	60e2                	ld	ra,24(sp)
    80000cb6:	6442                	ld	s0,16(sp)
    80000cb8:	64a2                	ld	s1,8(sp)
    80000cba:	6105                	add	sp,sp,32
    80000cbc:	8082                	ret
    panic("release");
    80000cbe:	00007517          	auipc	a0,0x7
    80000cc2:	3da50513          	add	a0,a0,986 # 80008098 <digits+0x58>
    80000cc6:	00000097          	auipc	ra,0x0
    80000cca:	876080e7          	jalr	-1930(ra) # 8000053c <panic>

0000000080000cce <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cce:	1141                	add	sp,sp,-16
    80000cd0:	e422                	sd	s0,8(sp)
    80000cd2:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd4:	ca19                	beqz	a2,80000cea <memset+0x1c>
    80000cd6:	87aa                	mv	a5,a0
    80000cd8:	1602                	sll	a2,a2,0x20
    80000cda:	9201                	srl	a2,a2,0x20
    80000cdc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce4:	0785                	add	a5,a5,1
    80000ce6:	fee79de3          	bne	a5,a4,80000ce0 <memset+0x12>
  }
  return dst;
}
    80000cea:	6422                	ld	s0,8(sp)
    80000cec:	0141                	add	sp,sp,16
    80000cee:	8082                	ret

0000000080000cf0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf0:	1141                	add	sp,sp,-16
    80000cf2:	e422                	sd	s0,8(sp)
    80000cf4:	0800                	add	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf6:	ca05                	beqz	a2,80000d26 <memcmp+0x36>
    80000cf8:	fff6069b          	addw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cfc:	1682                	sll	a3,a3,0x20
    80000cfe:	9281                	srl	a3,a3,0x20
    80000d00:	0685                	add	a3,a3,1
    80000d02:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d04:	00054783          	lbu	a5,0(a0)
    80000d08:	0005c703          	lbu	a4,0(a1)
    80000d0c:	00e79863          	bne	a5,a4,80000d1c <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d10:	0505                	add	a0,a0,1
    80000d12:	0585                	add	a1,a1,1
  while(n-- > 0){
    80000d14:	fed518e3          	bne	a0,a3,80000d04 <memcmp+0x14>
  }

  return 0;
    80000d18:	4501                	li	a0,0
    80000d1a:	a019                	j	80000d20 <memcmp+0x30>
      return *s1 - *s2;
    80000d1c:	40e7853b          	subw	a0,a5,a4
}
    80000d20:	6422                	ld	s0,8(sp)
    80000d22:	0141                	add	sp,sp,16
    80000d24:	8082                	ret
  return 0;
    80000d26:	4501                	li	a0,0
    80000d28:	bfe5                	j	80000d20 <memcmp+0x30>

0000000080000d2a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2a:	1141                	add	sp,sp,-16
    80000d2c:	e422                	sd	s0,8(sp)
    80000d2e:	0800                	add	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d30:	c205                	beqz	a2,80000d50 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d32:	02a5e263          	bltu	a1,a0,80000d56 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d36:	1602                	sll	a2,a2,0x20
    80000d38:	9201                	srl	a2,a2,0x20
    80000d3a:	00c587b3          	add	a5,a1,a2
{
    80000d3e:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d40:	0585                	add	a1,a1,1
    80000d42:	0705                	add	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdc821>
    80000d44:	fff5c683          	lbu	a3,-1(a1)
    80000d48:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d4c:	fef59ae3          	bne	a1,a5,80000d40 <memmove+0x16>

  return dst;
}
    80000d50:	6422                	ld	s0,8(sp)
    80000d52:	0141                	add	sp,sp,16
    80000d54:	8082                	ret
  if(s < d && s + n > d){
    80000d56:	02061693          	sll	a3,a2,0x20
    80000d5a:	9281                	srl	a3,a3,0x20
    80000d5c:	00d58733          	add	a4,a1,a3
    80000d60:	fce57be3          	bgeu	a0,a4,80000d36 <memmove+0xc>
    d += n;
    80000d64:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d66:	fff6079b          	addw	a5,a2,-1
    80000d6a:	1782                	sll	a5,a5,0x20
    80000d6c:	9381                	srl	a5,a5,0x20
    80000d6e:	fff7c793          	not	a5,a5
    80000d72:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d74:	177d                	add	a4,a4,-1
    80000d76:	16fd                	add	a3,a3,-1
    80000d78:	00074603          	lbu	a2,0(a4)
    80000d7c:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d80:	fee79ae3          	bne	a5,a4,80000d74 <memmove+0x4a>
    80000d84:	b7f1                	j	80000d50 <memmove+0x26>

0000000080000d86 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d86:	1141                	add	sp,sp,-16
    80000d88:	e406                	sd	ra,8(sp)
    80000d8a:	e022                	sd	s0,0(sp)
    80000d8c:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
    80000d8e:	00000097          	auipc	ra,0x0
    80000d92:	f9c080e7          	jalr	-100(ra) # 80000d2a <memmove>
}
    80000d96:	60a2                	ld	ra,8(sp)
    80000d98:	6402                	ld	s0,0(sp)
    80000d9a:	0141                	add	sp,sp,16
    80000d9c:	8082                	ret

0000000080000d9e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d9e:	1141                	add	sp,sp,-16
    80000da0:	e422                	sd	s0,8(sp)
    80000da2:	0800                	add	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da4:	ce11                	beqz	a2,80000dc0 <strncmp+0x22>
    80000da6:	00054783          	lbu	a5,0(a0)
    80000daa:	cf89                	beqz	a5,80000dc4 <strncmp+0x26>
    80000dac:	0005c703          	lbu	a4,0(a1)
    80000db0:	00f71a63          	bne	a4,a5,80000dc4 <strncmp+0x26>
    n--, p++, q++;
    80000db4:	367d                	addw	a2,a2,-1
    80000db6:	0505                	add	a0,a0,1
    80000db8:	0585                	add	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dba:	f675                	bnez	a2,80000da6 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dbc:	4501                	li	a0,0
    80000dbe:	a809                	j	80000dd0 <strncmp+0x32>
    80000dc0:	4501                	li	a0,0
    80000dc2:	a039                	j	80000dd0 <strncmp+0x32>
  if(n == 0)
    80000dc4:	ca09                	beqz	a2,80000dd6 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dc6:	00054503          	lbu	a0,0(a0)
    80000dca:	0005c783          	lbu	a5,0(a1)
    80000dce:	9d1d                	subw	a0,a0,a5
}
    80000dd0:	6422                	ld	s0,8(sp)
    80000dd2:	0141                	add	sp,sp,16
    80000dd4:	8082                	ret
    return 0;
    80000dd6:	4501                	li	a0,0
    80000dd8:	bfe5                	j	80000dd0 <strncmp+0x32>

0000000080000dda <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dda:	1141                	add	sp,sp,-16
    80000ddc:	e422                	sd	s0,8(sp)
    80000dde:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de0:	87aa                	mv	a5,a0
    80000de2:	86b2                	mv	a3,a2
    80000de4:	367d                	addw	a2,a2,-1
    80000de6:	00d05963          	blez	a3,80000df8 <strncpy+0x1e>
    80000dea:	0785                	add	a5,a5,1
    80000dec:	0005c703          	lbu	a4,0(a1)
    80000df0:	fee78fa3          	sb	a4,-1(a5)
    80000df4:	0585                	add	a1,a1,1
    80000df6:	f775                	bnez	a4,80000de2 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000df8:	873e                	mv	a4,a5
    80000dfa:	9fb5                	addw	a5,a5,a3
    80000dfc:	37fd                	addw	a5,a5,-1
    80000dfe:	00c05963          	blez	a2,80000e10 <strncpy+0x36>
    *s++ = 0;
    80000e02:	0705                	add	a4,a4,1
    80000e04:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e08:	40e786bb          	subw	a3,a5,a4
    80000e0c:	fed04be3          	bgtz	a3,80000e02 <strncpy+0x28>
  return os;
}
    80000e10:	6422                	ld	s0,8(sp)
    80000e12:	0141                	add	sp,sp,16
    80000e14:	8082                	ret

0000000080000e16 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e16:	1141                	add	sp,sp,-16
    80000e18:	e422                	sd	s0,8(sp)
    80000e1a:	0800                	add	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e1c:	02c05363          	blez	a2,80000e42 <safestrcpy+0x2c>
    80000e20:	fff6069b          	addw	a3,a2,-1
    80000e24:	1682                	sll	a3,a3,0x20
    80000e26:	9281                	srl	a3,a3,0x20
    80000e28:	96ae                	add	a3,a3,a1
    80000e2a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e2c:	00d58963          	beq	a1,a3,80000e3e <safestrcpy+0x28>
    80000e30:	0585                	add	a1,a1,1
    80000e32:	0785                	add	a5,a5,1
    80000e34:	fff5c703          	lbu	a4,-1(a1)
    80000e38:	fee78fa3          	sb	a4,-1(a5)
    80000e3c:	fb65                	bnez	a4,80000e2c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e3e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e42:	6422                	ld	s0,8(sp)
    80000e44:	0141                	add	sp,sp,16
    80000e46:	8082                	ret

0000000080000e48 <strlen>:

int
strlen(const char *s)
{
    80000e48:	1141                	add	sp,sp,-16
    80000e4a:	e422                	sd	s0,8(sp)
    80000e4c:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e4e:	00054783          	lbu	a5,0(a0)
    80000e52:	cf91                	beqz	a5,80000e6e <strlen+0x26>
    80000e54:	0505                	add	a0,a0,1
    80000e56:	87aa                	mv	a5,a0
    80000e58:	86be                	mv	a3,a5
    80000e5a:	0785                	add	a5,a5,1
    80000e5c:	fff7c703          	lbu	a4,-1(a5)
    80000e60:	ff65                	bnez	a4,80000e58 <strlen+0x10>
    80000e62:	40a6853b          	subw	a0,a3,a0
    80000e66:	2505                	addw	a0,a0,1
    ;
  return n;
}
    80000e68:	6422                	ld	s0,8(sp)
    80000e6a:	0141                	add	sp,sp,16
    80000e6c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e6e:	4501                	li	a0,0
    80000e70:	bfe5                	j	80000e68 <strlen+0x20>

0000000080000e72 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e72:	1141                	add	sp,sp,-16
    80000e74:	e406                	sd	ra,8(sp)
    80000e76:	e022                	sd	s0,0(sp)
    80000e78:	0800                	add	s0,sp,16
  if(cpuid() == 0){
    80000e7a:	00001097          	auipc	ra,0x1
    80000e7e:	b00080e7          	jalr	-1280(ra) # 8000197a <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e82:	00008717          	auipc	a4,0x8
    80000e86:	cc670713          	add	a4,a4,-826 # 80008b48 <started>
  if(cpuid() == 0){
    80000e8a:	c139                	beqz	a0,80000ed0 <main+0x5e>
    while(started == 0)
    80000e8c:	431c                	lw	a5,0(a4)
    80000e8e:	2781                	sext.w	a5,a5
    80000e90:	dff5                	beqz	a5,80000e8c <main+0x1a>
      ;
    __sync_synchronize();
    80000e92:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e96:	00001097          	auipc	ra,0x1
    80000e9a:	ae4080e7          	jalr	-1308(ra) # 8000197a <cpuid>
    80000e9e:	85aa                	mv	a1,a0
    80000ea0:	00007517          	auipc	a0,0x7
    80000ea4:	21850513          	add	a0,a0,536 # 800080b8 <digits+0x78>
    80000ea8:	fffff097          	auipc	ra,0xfffff
    80000eac:	6de080e7          	jalr	1758(ra) # 80000586 <printf>
    kvminithart();    // turn on paging
    80000eb0:	00000097          	auipc	ra,0x0
    80000eb4:	0d8080e7          	jalr	216(ra) # 80000f88 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb8:	00002097          	auipc	ra,0x2
    80000ebc:	a28080e7          	jalr	-1496(ra) # 800028e0 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec0:	00005097          	auipc	ra,0x5
    80000ec4:	130080e7          	jalr	304(ra) # 80005ff0 <plicinithart>
  }

  scheduler();        
    80000ec8:	00001097          	auipc	ra,0x1
    80000ecc:	0a6080e7          	jalr	166(ra) # 80001f6e <scheduler>
    consoleinit();
    80000ed0:	fffff097          	auipc	ra,0xfffff
    80000ed4:	57c080e7          	jalr	1404(ra) # 8000044c <consoleinit>
    printfinit();
    80000ed8:	00000097          	auipc	ra,0x0
    80000edc:	88e080e7          	jalr	-1906(ra) # 80000766 <printfinit>
    printf("\n");
    80000ee0:	00007517          	auipc	a0,0x7
    80000ee4:	1e850513          	add	a0,a0,488 # 800080c8 <digits+0x88>
    80000ee8:	fffff097          	auipc	ra,0xfffff
    80000eec:	69e080e7          	jalr	1694(ra) # 80000586 <printf>
    printf("xv6 kernel is booting\n");
    80000ef0:	00007517          	auipc	a0,0x7
    80000ef4:	1b050513          	add	a0,a0,432 # 800080a0 <digits+0x60>
    80000ef8:	fffff097          	auipc	ra,0xfffff
    80000efc:	68e080e7          	jalr	1678(ra) # 80000586 <printf>
    printf("\n");
    80000f00:	00007517          	auipc	a0,0x7
    80000f04:	1c850513          	add	a0,a0,456 # 800080c8 <digits+0x88>
    80000f08:	fffff097          	auipc	ra,0xfffff
    80000f0c:	67e080e7          	jalr	1662(ra) # 80000586 <printf>
    kinit();         // physical page allocator
    80000f10:	00000097          	auipc	ra,0x0
    80000f14:	b96080e7          	jalr	-1130(ra) # 80000aa6 <kinit>
    kvminit();       // create kernel page table
    80000f18:	00000097          	auipc	ra,0x0
    80000f1c:	326080e7          	jalr	806(ra) # 8000123e <kvminit>
    kvminithart();   // turn on paging
    80000f20:	00000097          	auipc	ra,0x0
    80000f24:	068080e7          	jalr	104(ra) # 80000f88 <kvminithart>
    procinit();      // process table
    80000f28:	00001097          	auipc	ra,0x1
    80000f2c:	99e080e7          	jalr	-1634(ra) # 800018c6 <procinit>
    trapinit();      // trap vectors
    80000f30:	00002097          	auipc	ra,0x2
    80000f34:	988080e7          	jalr	-1656(ra) # 800028b8 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f38:	00002097          	auipc	ra,0x2
    80000f3c:	9a8080e7          	jalr	-1624(ra) # 800028e0 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f40:	00005097          	auipc	ra,0x5
    80000f44:	09a080e7          	jalr	154(ra) # 80005fda <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f48:	00005097          	auipc	ra,0x5
    80000f4c:	0a8080e7          	jalr	168(ra) # 80005ff0 <plicinithart>
    binit();         // buffer cache
    80000f50:	00002097          	auipc	ra,0x2
    80000f54:	29e080e7          	jalr	670(ra) # 800031ee <binit>
    iinit();         // inode table
    80000f58:	00003097          	auipc	ra,0x3
    80000f5c:	93c080e7          	jalr	-1732(ra) # 80003894 <iinit>
    fileinit();      // file table
    80000f60:	00004097          	auipc	ra,0x4
    80000f64:	8b2080e7          	jalr	-1870(ra) # 80004812 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f68:	00005097          	auipc	ra,0x5
    80000f6c:	190080e7          	jalr	400(ra) # 800060f8 <virtio_disk_init>
    userinit();      // first user process
    80000f70:	00001097          	auipc	ra,0x1
    80000f74:	d2a080e7          	jalr	-726(ra) # 80001c9a <userinit>
    __sync_synchronize();
    80000f78:	0ff0000f          	fence
    started = 1;
    80000f7c:	4785                	li	a5,1
    80000f7e:	00008717          	auipc	a4,0x8
    80000f82:	bcf72523          	sw	a5,-1078(a4) # 80008b48 <started>
    80000f86:	b789                	j	80000ec8 <main+0x56>

0000000080000f88 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f88:	1141                	add	sp,sp,-16
    80000f8a:	e422                	sd	s0,8(sp)
    80000f8c:	0800                	add	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f8e:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f92:	00008797          	auipc	a5,0x8
    80000f96:	bbe7b783          	ld	a5,-1090(a5) # 80008b50 <kernel_pagetable>
    80000f9a:	83b1                	srl	a5,a5,0xc
    80000f9c:	577d                	li	a4,-1
    80000f9e:	177e                	sll	a4,a4,0x3f
    80000fa0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa2:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fa6:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000faa:	6422                	ld	s0,8(sp)
    80000fac:	0141                	add	sp,sp,16
    80000fae:	8082                	ret

0000000080000fb0 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb0:	7139                	add	sp,sp,-64
    80000fb2:	fc06                	sd	ra,56(sp)
    80000fb4:	f822                	sd	s0,48(sp)
    80000fb6:	f426                	sd	s1,40(sp)
    80000fb8:	f04a                	sd	s2,32(sp)
    80000fba:	ec4e                	sd	s3,24(sp)
    80000fbc:	e852                	sd	s4,16(sp)
    80000fbe:	e456                	sd	s5,8(sp)
    80000fc0:	e05a                	sd	s6,0(sp)
    80000fc2:	0080                	add	s0,sp,64
    80000fc4:	84aa                	mv	s1,a0
    80000fc6:	89ae                	mv	s3,a1
    80000fc8:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fca:	57fd                	li	a5,-1
    80000fcc:	83e9                	srl	a5,a5,0x1a
    80000fce:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd0:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd2:	04b7f263          	bgeu	a5,a1,80001016 <walk+0x66>
    panic("walk");
    80000fd6:	00007517          	auipc	a0,0x7
    80000fda:	0fa50513          	add	a0,a0,250 # 800080d0 <digits+0x90>
    80000fde:	fffff097          	auipc	ra,0xfffff
    80000fe2:	55e080e7          	jalr	1374(ra) # 8000053c <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fe6:	060a8663          	beqz	s5,80001052 <walk+0xa2>
    80000fea:	00000097          	auipc	ra,0x0
    80000fee:	af8080e7          	jalr	-1288(ra) # 80000ae2 <kalloc>
    80000ff2:	84aa                	mv	s1,a0
    80000ff4:	c529                	beqz	a0,8000103e <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ff6:	6605                	lui	a2,0x1
    80000ff8:	4581                	li	a1,0
    80000ffa:	00000097          	auipc	ra,0x0
    80000ffe:	cd4080e7          	jalr	-812(ra) # 80000cce <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001002:	00c4d793          	srl	a5,s1,0xc
    80001006:	07aa                	sll	a5,a5,0xa
    80001008:	0017e793          	or	a5,a5,1
    8000100c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001010:	3a5d                	addw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdc817>
    80001012:	036a0063          	beq	s4,s6,80001032 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001016:	0149d933          	srl	s2,s3,s4
    8000101a:	1ff97913          	and	s2,s2,511
    8000101e:	090e                	sll	s2,s2,0x3
    80001020:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001022:	00093483          	ld	s1,0(s2)
    80001026:	0014f793          	and	a5,s1,1
    8000102a:	dfd5                	beqz	a5,80000fe6 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000102c:	80a9                	srl	s1,s1,0xa
    8000102e:	04b2                	sll	s1,s1,0xc
    80001030:	b7c5                	j	80001010 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001032:	00c9d513          	srl	a0,s3,0xc
    80001036:	1ff57513          	and	a0,a0,511
    8000103a:	050e                	sll	a0,a0,0x3
    8000103c:	9526                	add	a0,a0,s1
}
    8000103e:	70e2                	ld	ra,56(sp)
    80001040:	7442                	ld	s0,48(sp)
    80001042:	74a2                	ld	s1,40(sp)
    80001044:	7902                	ld	s2,32(sp)
    80001046:	69e2                	ld	s3,24(sp)
    80001048:	6a42                	ld	s4,16(sp)
    8000104a:	6aa2                	ld	s5,8(sp)
    8000104c:	6b02                	ld	s6,0(sp)
    8000104e:	6121                	add	sp,sp,64
    80001050:	8082                	ret
        return 0;
    80001052:	4501                	li	a0,0
    80001054:	b7ed                	j	8000103e <walk+0x8e>

0000000080001056 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001056:	57fd                	li	a5,-1
    80001058:	83e9                	srl	a5,a5,0x1a
    8000105a:	00b7f463          	bgeu	a5,a1,80001062 <walkaddr+0xc>
    return 0;
    8000105e:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001060:	8082                	ret
{
    80001062:	1141                	add	sp,sp,-16
    80001064:	e406                	sd	ra,8(sp)
    80001066:	e022                	sd	s0,0(sp)
    80001068:	0800                	add	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000106a:	4601                	li	a2,0
    8000106c:	00000097          	auipc	ra,0x0
    80001070:	f44080e7          	jalr	-188(ra) # 80000fb0 <walk>
  if(pte == 0)
    80001074:	c105                	beqz	a0,80001094 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001076:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001078:	0117f693          	and	a3,a5,17
    8000107c:	4745                	li	a4,17
    return 0;
    8000107e:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001080:	00e68663          	beq	a3,a4,8000108c <walkaddr+0x36>
}
    80001084:	60a2                	ld	ra,8(sp)
    80001086:	6402                	ld	s0,0(sp)
    80001088:	0141                	add	sp,sp,16
    8000108a:	8082                	ret
  pa = PTE2PA(*pte);
    8000108c:	83a9                	srl	a5,a5,0xa
    8000108e:	00c79513          	sll	a0,a5,0xc
  return pa;
    80001092:	bfcd                	j	80001084 <walkaddr+0x2e>
    return 0;
    80001094:	4501                	li	a0,0
    80001096:	b7fd                	j	80001084 <walkaddr+0x2e>

0000000080001098 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001098:	715d                	add	sp,sp,-80
    8000109a:	e486                	sd	ra,72(sp)
    8000109c:	e0a2                	sd	s0,64(sp)
    8000109e:	fc26                	sd	s1,56(sp)
    800010a0:	f84a                	sd	s2,48(sp)
    800010a2:	f44e                	sd	s3,40(sp)
    800010a4:	f052                	sd	s4,32(sp)
    800010a6:	ec56                	sd	s5,24(sp)
    800010a8:	e85a                	sd	s6,16(sp)
    800010aa:	e45e                	sd	s7,8(sp)
    800010ac:	0880                	add	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010ae:	c639                	beqz	a2,800010fc <mappages+0x64>
    800010b0:	8aaa                	mv	s5,a0
    800010b2:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010b4:	777d                	lui	a4,0xfffff
    800010b6:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010ba:	fff58993          	add	s3,a1,-1
    800010be:	99b2                	add	s3,s3,a2
    800010c0:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010c4:	893e                	mv	s2,a5
    800010c6:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010ca:	6b85                	lui	s7,0x1
    800010cc:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d0:	4605                	li	a2,1
    800010d2:	85ca                	mv	a1,s2
    800010d4:	8556                	mv	a0,s5
    800010d6:	00000097          	auipc	ra,0x0
    800010da:	eda080e7          	jalr	-294(ra) # 80000fb0 <walk>
    800010de:	cd1d                	beqz	a0,8000111c <mappages+0x84>
    if(*pte & PTE_V)
    800010e0:	611c                	ld	a5,0(a0)
    800010e2:	8b85                	and	a5,a5,1
    800010e4:	e785                	bnez	a5,8000110c <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010e6:	80b1                	srl	s1,s1,0xc
    800010e8:	04aa                	sll	s1,s1,0xa
    800010ea:	0164e4b3          	or	s1,s1,s6
    800010ee:	0014e493          	or	s1,s1,1
    800010f2:	e104                	sd	s1,0(a0)
    if(a == last)
    800010f4:	05390063          	beq	s2,s3,80001134 <mappages+0x9c>
    a += PGSIZE;
    800010f8:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010fa:	bfc9                	j	800010cc <mappages+0x34>
    panic("mappages: size");
    800010fc:	00007517          	auipc	a0,0x7
    80001100:	fdc50513          	add	a0,a0,-36 # 800080d8 <digits+0x98>
    80001104:	fffff097          	auipc	ra,0xfffff
    80001108:	438080e7          	jalr	1080(ra) # 8000053c <panic>
      panic("mappages: remap");
    8000110c:	00007517          	auipc	a0,0x7
    80001110:	fdc50513          	add	a0,a0,-36 # 800080e8 <digits+0xa8>
    80001114:	fffff097          	auipc	ra,0xfffff
    80001118:	428080e7          	jalr	1064(ra) # 8000053c <panic>
      return -1;
    8000111c:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000111e:	60a6                	ld	ra,72(sp)
    80001120:	6406                	ld	s0,64(sp)
    80001122:	74e2                	ld	s1,56(sp)
    80001124:	7942                	ld	s2,48(sp)
    80001126:	79a2                	ld	s3,40(sp)
    80001128:	7a02                	ld	s4,32(sp)
    8000112a:	6ae2                	ld	s5,24(sp)
    8000112c:	6b42                	ld	s6,16(sp)
    8000112e:	6ba2                	ld	s7,8(sp)
    80001130:	6161                	add	sp,sp,80
    80001132:	8082                	ret
  return 0;
    80001134:	4501                	li	a0,0
    80001136:	b7e5                	j	8000111e <mappages+0x86>

0000000080001138 <kvmmap>:
{
    80001138:	1141                	add	sp,sp,-16
    8000113a:	e406                	sd	ra,8(sp)
    8000113c:	e022                	sd	s0,0(sp)
    8000113e:	0800                	add	s0,sp,16
    80001140:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001142:	86b2                	mv	a3,a2
    80001144:	863e                	mv	a2,a5
    80001146:	00000097          	auipc	ra,0x0
    8000114a:	f52080e7          	jalr	-174(ra) # 80001098 <mappages>
    8000114e:	e509                	bnez	a0,80001158 <kvmmap+0x20>
}
    80001150:	60a2                	ld	ra,8(sp)
    80001152:	6402                	ld	s0,0(sp)
    80001154:	0141                	add	sp,sp,16
    80001156:	8082                	ret
    panic("kvmmap");
    80001158:	00007517          	auipc	a0,0x7
    8000115c:	fa050513          	add	a0,a0,-96 # 800080f8 <digits+0xb8>
    80001160:	fffff097          	auipc	ra,0xfffff
    80001164:	3dc080e7          	jalr	988(ra) # 8000053c <panic>

0000000080001168 <kvmmake>:
{
    80001168:	1101                	add	sp,sp,-32
    8000116a:	ec06                	sd	ra,24(sp)
    8000116c:	e822                	sd	s0,16(sp)
    8000116e:	e426                	sd	s1,8(sp)
    80001170:	e04a                	sd	s2,0(sp)
    80001172:	1000                	add	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001174:	00000097          	auipc	ra,0x0
    80001178:	96e080e7          	jalr	-1682(ra) # 80000ae2 <kalloc>
    8000117c:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000117e:	6605                	lui	a2,0x1
    80001180:	4581                	li	a1,0
    80001182:	00000097          	auipc	ra,0x0
    80001186:	b4c080e7          	jalr	-1204(ra) # 80000cce <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000118a:	4719                	li	a4,6
    8000118c:	6685                	lui	a3,0x1
    8000118e:	10000637          	lui	a2,0x10000
    80001192:	100005b7          	lui	a1,0x10000
    80001196:	8526                	mv	a0,s1
    80001198:	00000097          	auipc	ra,0x0
    8000119c:	fa0080e7          	jalr	-96(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a0:	4719                	li	a4,6
    800011a2:	6685                	lui	a3,0x1
    800011a4:	10001637          	lui	a2,0x10001
    800011a8:	100015b7          	lui	a1,0x10001
    800011ac:	8526                	mv	a0,s1
    800011ae:	00000097          	auipc	ra,0x0
    800011b2:	f8a080e7          	jalr	-118(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011b6:	4719                	li	a4,6
    800011b8:	004006b7          	lui	a3,0x400
    800011bc:	0c000637          	lui	a2,0xc000
    800011c0:	0c0005b7          	lui	a1,0xc000
    800011c4:	8526                	mv	a0,s1
    800011c6:	00000097          	auipc	ra,0x0
    800011ca:	f72080e7          	jalr	-142(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011ce:	00007917          	auipc	s2,0x7
    800011d2:	e3290913          	add	s2,s2,-462 # 80008000 <etext>
    800011d6:	4729                	li	a4,10
    800011d8:	80007697          	auipc	a3,0x80007
    800011dc:	e2868693          	add	a3,a3,-472 # 8000 <_entry-0x7fff8000>
    800011e0:	4605                	li	a2,1
    800011e2:	067e                	sll	a2,a2,0x1f
    800011e4:	85b2                	mv	a1,a2
    800011e6:	8526                	mv	a0,s1
    800011e8:	00000097          	auipc	ra,0x0
    800011ec:	f50080e7          	jalr	-176(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f0:	4719                	li	a4,6
    800011f2:	46c5                	li	a3,17
    800011f4:	06ee                	sll	a3,a3,0x1b
    800011f6:	412686b3          	sub	a3,a3,s2
    800011fa:	864a                	mv	a2,s2
    800011fc:	85ca                	mv	a1,s2
    800011fe:	8526                	mv	a0,s1
    80001200:	00000097          	auipc	ra,0x0
    80001204:	f38080e7          	jalr	-200(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001208:	4729                	li	a4,10
    8000120a:	6685                	lui	a3,0x1
    8000120c:	00006617          	auipc	a2,0x6
    80001210:	df460613          	add	a2,a2,-524 # 80007000 <_trampoline>
    80001214:	040005b7          	lui	a1,0x4000
    80001218:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000121a:	05b2                	sll	a1,a1,0xc
    8000121c:	8526                	mv	a0,s1
    8000121e:	00000097          	auipc	ra,0x0
    80001222:	f1a080e7          	jalr	-230(ra) # 80001138 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001226:	8526                	mv	a0,s1
    80001228:	00000097          	auipc	ra,0x0
    8000122c:	608080e7          	jalr	1544(ra) # 80001830 <proc_mapstacks>
}
    80001230:	8526                	mv	a0,s1
    80001232:	60e2                	ld	ra,24(sp)
    80001234:	6442                	ld	s0,16(sp)
    80001236:	64a2                	ld	s1,8(sp)
    80001238:	6902                	ld	s2,0(sp)
    8000123a:	6105                	add	sp,sp,32
    8000123c:	8082                	ret

000000008000123e <kvminit>:
{
    8000123e:	1141                	add	sp,sp,-16
    80001240:	e406                	sd	ra,8(sp)
    80001242:	e022                	sd	s0,0(sp)
    80001244:	0800                	add	s0,sp,16
  kernel_pagetable = kvmmake();
    80001246:	00000097          	auipc	ra,0x0
    8000124a:	f22080e7          	jalr	-222(ra) # 80001168 <kvmmake>
    8000124e:	00008797          	auipc	a5,0x8
    80001252:	90a7b123          	sd	a0,-1790(a5) # 80008b50 <kernel_pagetable>
}
    80001256:	60a2                	ld	ra,8(sp)
    80001258:	6402                	ld	s0,0(sp)
    8000125a:	0141                	add	sp,sp,16
    8000125c:	8082                	ret

000000008000125e <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000125e:	715d                	add	sp,sp,-80
    80001260:	e486                	sd	ra,72(sp)
    80001262:	e0a2                	sd	s0,64(sp)
    80001264:	fc26                	sd	s1,56(sp)
    80001266:	f84a                	sd	s2,48(sp)
    80001268:	f44e                	sd	s3,40(sp)
    8000126a:	f052                	sd	s4,32(sp)
    8000126c:	ec56                	sd	s5,24(sp)
    8000126e:	e85a                	sd	s6,16(sp)
    80001270:	e45e                	sd	s7,8(sp)
    80001272:	0880                	add	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001274:	03459793          	sll	a5,a1,0x34
    80001278:	e795                	bnez	a5,800012a4 <uvmunmap+0x46>
    8000127a:	8a2a                	mv	s4,a0
    8000127c:	892e                	mv	s2,a1
    8000127e:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001280:	0632                	sll	a2,a2,0xc
    80001282:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001286:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001288:	6b05                	lui	s6,0x1
    8000128a:	0735e263          	bltu	a1,s3,800012ee <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000128e:	60a6                	ld	ra,72(sp)
    80001290:	6406                	ld	s0,64(sp)
    80001292:	74e2                	ld	s1,56(sp)
    80001294:	7942                	ld	s2,48(sp)
    80001296:	79a2                	ld	s3,40(sp)
    80001298:	7a02                	ld	s4,32(sp)
    8000129a:	6ae2                	ld	s5,24(sp)
    8000129c:	6b42                	ld	s6,16(sp)
    8000129e:	6ba2                	ld	s7,8(sp)
    800012a0:	6161                	add	sp,sp,80
    800012a2:	8082                	ret
    panic("uvmunmap: not aligned");
    800012a4:	00007517          	auipc	a0,0x7
    800012a8:	e5c50513          	add	a0,a0,-420 # 80008100 <digits+0xc0>
    800012ac:	fffff097          	auipc	ra,0xfffff
    800012b0:	290080e7          	jalr	656(ra) # 8000053c <panic>
      panic("uvmunmap: walk");
    800012b4:	00007517          	auipc	a0,0x7
    800012b8:	e6450513          	add	a0,a0,-412 # 80008118 <digits+0xd8>
    800012bc:	fffff097          	auipc	ra,0xfffff
    800012c0:	280080e7          	jalr	640(ra) # 8000053c <panic>
      panic("uvmunmap: not mapped");
    800012c4:	00007517          	auipc	a0,0x7
    800012c8:	e6450513          	add	a0,a0,-412 # 80008128 <digits+0xe8>
    800012cc:	fffff097          	auipc	ra,0xfffff
    800012d0:	270080e7          	jalr	624(ra) # 8000053c <panic>
      panic("uvmunmap: not a leaf");
    800012d4:	00007517          	auipc	a0,0x7
    800012d8:	e6c50513          	add	a0,a0,-404 # 80008140 <digits+0x100>
    800012dc:	fffff097          	auipc	ra,0xfffff
    800012e0:	260080e7          	jalr	608(ra) # 8000053c <panic>
    *pte = 0;
    800012e4:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012e8:	995a                	add	s2,s2,s6
    800012ea:	fb3972e3          	bgeu	s2,s3,8000128e <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012ee:	4601                	li	a2,0
    800012f0:	85ca                	mv	a1,s2
    800012f2:	8552                	mv	a0,s4
    800012f4:	00000097          	auipc	ra,0x0
    800012f8:	cbc080e7          	jalr	-836(ra) # 80000fb0 <walk>
    800012fc:	84aa                	mv	s1,a0
    800012fe:	d95d                	beqz	a0,800012b4 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001300:	6108                	ld	a0,0(a0)
    80001302:	00157793          	and	a5,a0,1
    80001306:	dfdd                	beqz	a5,800012c4 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001308:	3ff57793          	and	a5,a0,1023
    8000130c:	fd7784e3          	beq	a5,s7,800012d4 <uvmunmap+0x76>
    if(do_free){
    80001310:	fc0a8ae3          	beqz	s5,800012e4 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001314:	8129                	srl	a0,a0,0xa
      kfree((void*)pa);
    80001316:	0532                	sll	a0,a0,0xc
    80001318:	fffff097          	auipc	ra,0xfffff
    8000131c:	6cc080e7          	jalr	1740(ra) # 800009e4 <kfree>
    80001320:	b7d1                	j	800012e4 <uvmunmap+0x86>

0000000080001322 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001322:	1101                	add	sp,sp,-32
    80001324:	ec06                	sd	ra,24(sp)
    80001326:	e822                	sd	s0,16(sp)
    80001328:	e426                	sd	s1,8(sp)
    8000132a:	1000                	add	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000132c:	fffff097          	auipc	ra,0xfffff
    80001330:	7b6080e7          	jalr	1974(ra) # 80000ae2 <kalloc>
    80001334:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001336:	c519                	beqz	a0,80001344 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001338:	6605                	lui	a2,0x1
    8000133a:	4581                	li	a1,0
    8000133c:	00000097          	auipc	ra,0x0
    80001340:	992080e7          	jalr	-1646(ra) # 80000cce <memset>
  return pagetable;
}
    80001344:	8526                	mv	a0,s1
    80001346:	60e2                	ld	ra,24(sp)
    80001348:	6442                	ld	s0,16(sp)
    8000134a:	64a2                	ld	s1,8(sp)
    8000134c:	6105                	add	sp,sp,32
    8000134e:	8082                	ret

0000000080001350 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001350:	7179                	add	sp,sp,-48
    80001352:	f406                	sd	ra,40(sp)
    80001354:	f022                	sd	s0,32(sp)
    80001356:	ec26                	sd	s1,24(sp)
    80001358:	e84a                	sd	s2,16(sp)
    8000135a:	e44e                	sd	s3,8(sp)
    8000135c:	e052                	sd	s4,0(sp)
    8000135e:	1800                	add	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001360:	6785                	lui	a5,0x1
    80001362:	04f67863          	bgeu	a2,a5,800013b2 <uvmfirst+0x62>
    80001366:	8a2a                	mv	s4,a0
    80001368:	89ae                	mv	s3,a1
    8000136a:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000136c:	fffff097          	auipc	ra,0xfffff
    80001370:	776080e7          	jalr	1910(ra) # 80000ae2 <kalloc>
    80001374:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001376:	6605                	lui	a2,0x1
    80001378:	4581                	li	a1,0
    8000137a:	00000097          	auipc	ra,0x0
    8000137e:	954080e7          	jalr	-1708(ra) # 80000cce <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001382:	4779                	li	a4,30
    80001384:	86ca                	mv	a3,s2
    80001386:	6605                	lui	a2,0x1
    80001388:	4581                	li	a1,0
    8000138a:	8552                	mv	a0,s4
    8000138c:	00000097          	auipc	ra,0x0
    80001390:	d0c080e7          	jalr	-756(ra) # 80001098 <mappages>
  memmove(mem, src, sz);
    80001394:	8626                	mv	a2,s1
    80001396:	85ce                	mv	a1,s3
    80001398:	854a                	mv	a0,s2
    8000139a:	00000097          	auipc	ra,0x0
    8000139e:	990080e7          	jalr	-1648(ra) # 80000d2a <memmove>
}
    800013a2:	70a2                	ld	ra,40(sp)
    800013a4:	7402                	ld	s0,32(sp)
    800013a6:	64e2                	ld	s1,24(sp)
    800013a8:	6942                	ld	s2,16(sp)
    800013aa:	69a2                	ld	s3,8(sp)
    800013ac:	6a02                	ld	s4,0(sp)
    800013ae:	6145                	add	sp,sp,48
    800013b0:	8082                	ret
    panic("uvmfirst: more than a page");
    800013b2:	00007517          	auipc	a0,0x7
    800013b6:	da650513          	add	a0,a0,-602 # 80008158 <digits+0x118>
    800013ba:	fffff097          	auipc	ra,0xfffff
    800013be:	182080e7          	jalr	386(ra) # 8000053c <panic>

00000000800013c2 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c2:	1101                	add	sp,sp,-32
    800013c4:	ec06                	sd	ra,24(sp)
    800013c6:	e822                	sd	s0,16(sp)
    800013c8:	e426                	sd	s1,8(sp)
    800013ca:	1000                	add	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013cc:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013ce:	00b67d63          	bgeu	a2,a1,800013e8 <uvmdealloc+0x26>
    800013d2:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013d4:	6785                	lui	a5,0x1
    800013d6:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013d8:	00f60733          	add	a4,a2,a5
    800013dc:	76fd                	lui	a3,0xfffff
    800013de:	8f75                	and	a4,a4,a3
    800013e0:	97ae                	add	a5,a5,a1
    800013e2:	8ff5                	and	a5,a5,a3
    800013e4:	00f76863          	bltu	a4,a5,800013f4 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013e8:	8526                	mv	a0,s1
    800013ea:	60e2                	ld	ra,24(sp)
    800013ec:	6442                	ld	s0,16(sp)
    800013ee:	64a2                	ld	s1,8(sp)
    800013f0:	6105                	add	sp,sp,32
    800013f2:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013f4:	8f99                	sub	a5,a5,a4
    800013f6:	83b1                	srl	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013f8:	4685                	li	a3,1
    800013fa:	0007861b          	sext.w	a2,a5
    800013fe:	85ba                	mv	a1,a4
    80001400:	00000097          	auipc	ra,0x0
    80001404:	e5e080e7          	jalr	-418(ra) # 8000125e <uvmunmap>
    80001408:	b7c5                	j	800013e8 <uvmdealloc+0x26>

000000008000140a <uvmalloc>:
  if(newsz < oldsz)
    8000140a:	0ab66563          	bltu	a2,a1,800014b4 <uvmalloc+0xaa>
{
    8000140e:	7139                	add	sp,sp,-64
    80001410:	fc06                	sd	ra,56(sp)
    80001412:	f822                	sd	s0,48(sp)
    80001414:	f426                	sd	s1,40(sp)
    80001416:	f04a                	sd	s2,32(sp)
    80001418:	ec4e                	sd	s3,24(sp)
    8000141a:	e852                	sd	s4,16(sp)
    8000141c:	e456                	sd	s5,8(sp)
    8000141e:	e05a                	sd	s6,0(sp)
    80001420:	0080                	add	s0,sp,64
    80001422:	8aaa                	mv	s5,a0
    80001424:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001426:	6785                	lui	a5,0x1
    80001428:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000142a:	95be                	add	a1,a1,a5
    8000142c:	77fd                	lui	a5,0xfffff
    8000142e:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001432:	08c9f363          	bgeu	s3,a2,800014b8 <uvmalloc+0xae>
    80001436:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001438:	0126eb13          	or	s6,a3,18
    mem = kalloc();
    8000143c:	fffff097          	auipc	ra,0xfffff
    80001440:	6a6080e7          	jalr	1702(ra) # 80000ae2 <kalloc>
    80001444:	84aa                	mv	s1,a0
    if(mem == 0){
    80001446:	c51d                	beqz	a0,80001474 <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    80001448:	6605                	lui	a2,0x1
    8000144a:	4581                	li	a1,0
    8000144c:	00000097          	auipc	ra,0x0
    80001450:	882080e7          	jalr	-1918(ra) # 80000cce <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001454:	875a                	mv	a4,s6
    80001456:	86a6                	mv	a3,s1
    80001458:	6605                	lui	a2,0x1
    8000145a:	85ca                	mv	a1,s2
    8000145c:	8556                	mv	a0,s5
    8000145e:	00000097          	auipc	ra,0x0
    80001462:	c3a080e7          	jalr	-966(ra) # 80001098 <mappages>
    80001466:	e90d                	bnez	a0,80001498 <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001468:	6785                	lui	a5,0x1
    8000146a:	993e                	add	s2,s2,a5
    8000146c:	fd4968e3          	bltu	s2,s4,8000143c <uvmalloc+0x32>
  return newsz;
    80001470:	8552                	mv	a0,s4
    80001472:	a809                	j	80001484 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    80001474:	864e                	mv	a2,s3
    80001476:	85ca                	mv	a1,s2
    80001478:	8556                	mv	a0,s5
    8000147a:	00000097          	auipc	ra,0x0
    8000147e:	f48080e7          	jalr	-184(ra) # 800013c2 <uvmdealloc>
      return 0;
    80001482:	4501                	li	a0,0
}
    80001484:	70e2                	ld	ra,56(sp)
    80001486:	7442                	ld	s0,48(sp)
    80001488:	74a2                	ld	s1,40(sp)
    8000148a:	7902                	ld	s2,32(sp)
    8000148c:	69e2                	ld	s3,24(sp)
    8000148e:	6a42                	ld	s4,16(sp)
    80001490:	6aa2                	ld	s5,8(sp)
    80001492:	6b02                	ld	s6,0(sp)
    80001494:	6121                	add	sp,sp,64
    80001496:	8082                	ret
      kfree(mem);
    80001498:	8526                	mv	a0,s1
    8000149a:	fffff097          	auipc	ra,0xfffff
    8000149e:	54a080e7          	jalr	1354(ra) # 800009e4 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a2:	864e                	mv	a2,s3
    800014a4:	85ca                	mv	a1,s2
    800014a6:	8556                	mv	a0,s5
    800014a8:	00000097          	auipc	ra,0x0
    800014ac:	f1a080e7          	jalr	-230(ra) # 800013c2 <uvmdealloc>
      return 0;
    800014b0:	4501                	li	a0,0
    800014b2:	bfc9                	j	80001484 <uvmalloc+0x7a>
    return oldsz;
    800014b4:	852e                	mv	a0,a1
}
    800014b6:	8082                	ret
  return newsz;
    800014b8:	8532                	mv	a0,a2
    800014ba:	b7e9                	j	80001484 <uvmalloc+0x7a>

00000000800014bc <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014bc:	7179                	add	sp,sp,-48
    800014be:	f406                	sd	ra,40(sp)
    800014c0:	f022                	sd	s0,32(sp)
    800014c2:	ec26                	sd	s1,24(sp)
    800014c4:	e84a                	sd	s2,16(sp)
    800014c6:	e44e                	sd	s3,8(sp)
    800014c8:	e052                	sd	s4,0(sp)
    800014ca:	1800                	add	s0,sp,48
    800014cc:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014ce:	84aa                	mv	s1,a0
    800014d0:	6905                	lui	s2,0x1
    800014d2:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014d4:	4985                	li	s3,1
    800014d6:	a829                	j	800014f0 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014d8:	83a9                	srl	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014da:	00c79513          	sll	a0,a5,0xc
    800014de:	00000097          	auipc	ra,0x0
    800014e2:	fde080e7          	jalr	-34(ra) # 800014bc <freewalk>
      pagetable[i] = 0;
    800014e6:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014ea:	04a1                	add	s1,s1,8
    800014ec:	03248163          	beq	s1,s2,8000150e <freewalk+0x52>
    pte_t pte = pagetable[i];
    800014f0:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f2:	00f7f713          	and	a4,a5,15
    800014f6:	ff3701e3          	beq	a4,s3,800014d8 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014fa:	8b85                	and	a5,a5,1
    800014fc:	d7fd                	beqz	a5,800014ea <freewalk+0x2e>
      panic("freewalk: leaf");
    800014fe:	00007517          	auipc	a0,0x7
    80001502:	c7a50513          	add	a0,a0,-902 # 80008178 <digits+0x138>
    80001506:	fffff097          	auipc	ra,0xfffff
    8000150a:	036080e7          	jalr	54(ra) # 8000053c <panic>
    }
  }
  kfree((void*)pagetable);
    8000150e:	8552                	mv	a0,s4
    80001510:	fffff097          	auipc	ra,0xfffff
    80001514:	4d4080e7          	jalr	1236(ra) # 800009e4 <kfree>
}
    80001518:	70a2                	ld	ra,40(sp)
    8000151a:	7402                	ld	s0,32(sp)
    8000151c:	64e2                	ld	s1,24(sp)
    8000151e:	6942                	ld	s2,16(sp)
    80001520:	69a2                	ld	s3,8(sp)
    80001522:	6a02                	ld	s4,0(sp)
    80001524:	6145                	add	sp,sp,48
    80001526:	8082                	ret

0000000080001528 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001528:	1101                	add	sp,sp,-32
    8000152a:	ec06                	sd	ra,24(sp)
    8000152c:	e822                	sd	s0,16(sp)
    8000152e:	e426                	sd	s1,8(sp)
    80001530:	1000                	add	s0,sp,32
    80001532:	84aa                	mv	s1,a0
  if(sz > 0)
    80001534:	e999                	bnez	a1,8000154a <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001536:	8526                	mv	a0,s1
    80001538:	00000097          	auipc	ra,0x0
    8000153c:	f84080e7          	jalr	-124(ra) # 800014bc <freewalk>
}
    80001540:	60e2                	ld	ra,24(sp)
    80001542:	6442                	ld	s0,16(sp)
    80001544:	64a2                	ld	s1,8(sp)
    80001546:	6105                	add	sp,sp,32
    80001548:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000154a:	6785                	lui	a5,0x1
    8000154c:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000154e:	95be                	add	a1,a1,a5
    80001550:	4685                	li	a3,1
    80001552:	00c5d613          	srl	a2,a1,0xc
    80001556:	4581                	li	a1,0
    80001558:	00000097          	auipc	ra,0x0
    8000155c:	d06080e7          	jalr	-762(ra) # 8000125e <uvmunmap>
    80001560:	bfd9                	j	80001536 <uvmfree+0xe>

0000000080001562 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001562:	c679                	beqz	a2,80001630 <uvmcopy+0xce>
{
    80001564:	715d                	add	sp,sp,-80
    80001566:	e486                	sd	ra,72(sp)
    80001568:	e0a2                	sd	s0,64(sp)
    8000156a:	fc26                	sd	s1,56(sp)
    8000156c:	f84a                	sd	s2,48(sp)
    8000156e:	f44e                	sd	s3,40(sp)
    80001570:	f052                	sd	s4,32(sp)
    80001572:	ec56                	sd	s5,24(sp)
    80001574:	e85a                	sd	s6,16(sp)
    80001576:	e45e                	sd	s7,8(sp)
    80001578:	0880                	add	s0,sp,80
    8000157a:	8b2a                	mv	s6,a0
    8000157c:	8aae                	mv	s5,a1
    8000157e:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001580:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001582:	4601                	li	a2,0
    80001584:	85ce                	mv	a1,s3
    80001586:	855a                	mv	a0,s6
    80001588:	00000097          	auipc	ra,0x0
    8000158c:	a28080e7          	jalr	-1496(ra) # 80000fb0 <walk>
    80001590:	c531                	beqz	a0,800015dc <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001592:	6118                	ld	a4,0(a0)
    80001594:	00177793          	and	a5,a4,1
    80001598:	cbb1                	beqz	a5,800015ec <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000159a:	00a75593          	srl	a1,a4,0xa
    8000159e:	00c59b93          	sll	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a2:	3ff77493          	and	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015a6:	fffff097          	auipc	ra,0xfffff
    800015aa:	53c080e7          	jalr	1340(ra) # 80000ae2 <kalloc>
    800015ae:	892a                	mv	s2,a0
    800015b0:	c939                	beqz	a0,80001606 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b2:	6605                	lui	a2,0x1
    800015b4:	85de                	mv	a1,s7
    800015b6:	fffff097          	auipc	ra,0xfffff
    800015ba:	774080e7          	jalr	1908(ra) # 80000d2a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015be:	8726                	mv	a4,s1
    800015c0:	86ca                	mv	a3,s2
    800015c2:	6605                	lui	a2,0x1
    800015c4:	85ce                	mv	a1,s3
    800015c6:	8556                	mv	a0,s5
    800015c8:	00000097          	auipc	ra,0x0
    800015cc:	ad0080e7          	jalr	-1328(ra) # 80001098 <mappages>
    800015d0:	e515                	bnez	a0,800015fc <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d2:	6785                	lui	a5,0x1
    800015d4:	99be                	add	s3,s3,a5
    800015d6:	fb49e6e3          	bltu	s3,s4,80001582 <uvmcopy+0x20>
    800015da:	a081                	j	8000161a <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015dc:	00007517          	auipc	a0,0x7
    800015e0:	bac50513          	add	a0,a0,-1108 # 80008188 <digits+0x148>
    800015e4:	fffff097          	auipc	ra,0xfffff
    800015e8:	f58080e7          	jalr	-168(ra) # 8000053c <panic>
      panic("uvmcopy: page not present");
    800015ec:	00007517          	auipc	a0,0x7
    800015f0:	bbc50513          	add	a0,a0,-1092 # 800081a8 <digits+0x168>
    800015f4:	fffff097          	auipc	ra,0xfffff
    800015f8:	f48080e7          	jalr	-184(ra) # 8000053c <panic>
      kfree(mem);
    800015fc:	854a                	mv	a0,s2
    800015fe:	fffff097          	auipc	ra,0xfffff
    80001602:	3e6080e7          	jalr	998(ra) # 800009e4 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001606:	4685                	li	a3,1
    80001608:	00c9d613          	srl	a2,s3,0xc
    8000160c:	4581                	li	a1,0
    8000160e:	8556                	mv	a0,s5
    80001610:	00000097          	auipc	ra,0x0
    80001614:	c4e080e7          	jalr	-946(ra) # 8000125e <uvmunmap>
  return -1;
    80001618:	557d                	li	a0,-1
}
    8000161a:	60a6                	ld	ra,72(sp)
    8000161c:	6406                	ld	s0,64(sp)
    8000161e:	74e2                	ld	s1,56(sp)
    80001620:	7942                	ld	s2,48(sp)
    80001622:	79a2                	ld	s3,40(sp)
    80001624:	7a02                	ld	s4,32(sp)
    80001626:	6ae2                	ld	s5,24(sp)
    80001628:	6b42                	ld	s6,16(sp)
    8000162a:	6ba2                	ld	s7,8(sp)
    8000162c:	6161                	add	sp,sp,80
    8000162e:	8082                	ret
  return 0;
    80001630:	4501                	li	a0,0
}
    80001632:	8082                	ret

0000000080001634 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001634:	1141                	add	sp,sp,-16
    80001636:	e406                	sd	ra,8(sp)
    80001638:	e022                	sd	s0,0(sp)
    8000163a:	0800                	add	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000163c:	4601                	li	a2,0
    8000163e:	00000097          	auipc	ra,0x0
    80001642:	972080e7          	jalr	-1678(ra) # 80000fb0 <walk>
  if(pte == 0)
    80001646:	c901                	beqz	a0,80001656 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001648:	611c                	ld	a5,0(a0)
    8000164a:	9bbd                	and	a5,a5,-17
    8000164c:	e11c                	sd	a5,0(a0)
}
    8000164e:	60a2                	ld	ra,8(sp)
    80001650:	6402                	ld	s0,0(sp)
    80001652:	0141                	add	sp,sp,16
    80001654:	8082                	ret
    panic("uvmclear");
    80001656:	00007517          	auipc	a0,0x7
    8000165a:	b7250513          	add	a0,a0,-1166 # 800081c8 <digits+0x188>
    8000165e:	fffff097          	auipc	ra,0xfffff
    80001662:	ede080e7          	jalr	-290(ra) # 8000053c <panic>

0000000080001666 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001666:	c6bd                	beqz	a3,800016d4 <copyout+0x6e>
{
    80001668:	715d                	add	sp,sp,-80
    8000166a:	e486                	sd	ra,72(sp)
    8000166c:	e0a2                	sd	s0,64(sp)
    8000166e:	fc26                	sd	s1,56(sp)
    80001670:	f84a                	sd	s2,48(sp)
    80001672:	f44e                	sd	s3,40(sp)
    80001674:	f052                	sd	s4,32(sp)
    80001676:	ec56                	sd	s5,24(sp)
    80001678:	e85a                	sd	s6,16(sp)
    8000167a:	e45e                	sd	s7,8(sp)
    8000167c:	e062                	sd	s8,0(sp)
    8000167e:	0880                	add	s0,sp,80
    80001680:	8b2a                	mv	s6,a0
    80001682:	8c2e                	mv	s8,a1
    80001684:	8a32                	mv	s4,a2
    80001686:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001688:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000168a:	6a85                	lui	s5,0x1
    8000168c:	a015                	j	800016b0 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000168e:	9562                	add	a0,a0,s8
    80001690:	0004861b          	sext.w	a2,s1
    80001694:	85d2                	mv	a1,s4
    80001696:	41250533          	sub	a0,a0,s2
    8000169a:	fffff097          	auipc	ra,0xfffff
    8000169e:	690080e7          	jalr	1680(ra) # 80000d2a <memmove>

    len -= n;
    800016a2:	409989b3          	sub	s3,s3,s1
    src += n;
    800016a6:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016a8:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016ac:	02098263          	beqz	s3,800016d0 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b0:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016b4:	85ca                	mv	a1,s2
    800016b6:	855a                	mv	a0,s6
    800016b8:	00000097          	auipc	ra,0x0
    800016bc:	99e080e7          	jalr	-1634(ra) # 80001056 <walkaddr>
    if(pa0 == 0)
    800016c0:	cd01                	beqz	a0,800016d8 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c2:	418904b3          	sub	s1,s2,s8
    800016c6:	94d6                	add	s1,s1,s5
    800016c8:	fc99f3e3          	bgeu	s3,s1,8000168e <copyout+0x28>
    800016cc:	84ce                	mv	s1,s3
    800016ce:	b7c1                	j	8000168e <copyout+0x28>
  }
  return 0;
    800016d0:	4501                	li	a0,0
    800016d2:	a021                	j	800016da <copyout+0x74>
    800016d4:	4501                	li	a0,0
}
    800016d6:	8082                	ret
      return -1;
    800016d8:	557d                	li	a0,-1
}
    800016da:	60a6                	ld	ra,72(sp)
    800016dc:	6406                	ld	s0,64(sp)
    800016de:	74e2                	ld	s1,56(sp)
    800016e0:	7942                	ld	s2,48(sp)
    800016e2:	79a2                	ld	s3,40(sp)
    800016e4:	7a02                	ld	s4,32(sp)
    800016e6:	6ae2                	ld	s5,24(sp)
    800016e8:	6b42                	ld	s6,16(sp)
    800016ea:	6ba2                	ld	s7,8(sp)
    800016ec:	6c02                	ld	s8,0(sp)
    800016ee:	6161                	add	sp,sp,80
    800016f0:	8082                	ret

00000000800016f2 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f2:	caa5                	beqz	a3,80001762 <copyin+0x70>
{
    800016f4:	715d                	add	sp,sp,-80
    800016f6:	e486                	sd	ra,72(sp)
    800016f8:	e0a2                	sd	s0,64(sp)
    800016fa:	fc26                	sd	s1,56(sp)
    800016fc:	f84a                	sd	s2,48(sp)
    800016fe:	f44e                	sd	s3,40(sp)
    80001700:	f052                	sd	s4,32(sp)
    80001702:	ec56                	sd	s5,24(sp)
    80001704:	e85a                	sd	s6,16(sp)
    80001706:	e45e                	sd	s7,8(sp)
    80001708:	e062                	sd	s8,0(sp)
    8000170a:	0880                	add	s0,sp,80
    8000170c:	8b2a                	mv	s6,a0
    8000170e:	8a2e                	mv	s4,a1
    80001710:	8c32                	mv	s8,a2
    80001712:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001714:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001716:	6a85                	lui	s5,0x1
    80001718:	a01d                	j	8000173e <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000171a:	018505b3          	add	a1,a0,s8
    8000171e:	0004861b          	sext.w	a2,s1
    80001722:	412585b3          	sub	a1,a1,s2
    80001726:	8552                	mv	a0,s4
    80001728:	fffff097          	auipc	ra,0xfffff
    8000172c:	602080e7          	jalr	1538(ra) # 80000d2a <memmove>

    len -= n;
    80001730:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001734:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001736:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000173a:	02098263          	beqz	s3,8000175e <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000173e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001742:	85ca                	mv	a1,s2
    80001744:	855a                	mv	a0,s6
    80001746:	00000097          	auipc	ra,0x0
    8000174a:	910080e7          	jalr	-1776(ra) # 80001056 <walkaddr>
    if(pa0 == 0)
    8000174e:	cd01                	beqz	a0,80001766 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001750:	418904b3          	sub	s1,s2,s8
    80001754:	94d6                	add	s1,s1,s5
    80001756:	fc99f2e3          	bgeu	s3,s1,8000171a <copyin+0x28>
    8000175a:	84ce                	mv	s1,s3
    8000175c:	bf7d                	j	8000171a <copyin+0x28>
  }
  return 0;
    8000175e:	4501                	li	a0,0
    80001760:	a021                	j	80001768 <copyin+0x76>
    80001762:	4501                	li	a0,0
}
    80001764:	8082                	ret
      return -1;
    80001766:	557d                	li	a0,-1
}
    80001768:	60a6                	ld	ra,72(sp)
    8000176a:	6406                	ld	s0,64(sp)
    8000176c:	74e2                	ld	s1,56(sp)
    8000176e:	7942                	ld	s2,48(sp)
    80001770:	79a2                	ld	s3,40(sp)
    80001772:	7a02                	ld	s4,32(sp)
    80001774:	6ae2                	ld	s5,24(sp)
    80001776:	6b42                	ld	s6,16(sp)
    80001778:	6ba2                	ld	s7,8(sp)
    8000177a:	6c02                	ld	s8,0(sp)
    8000177c:	6161                	add	sp,sp,80
    8000177e:	8082                	ret

0000000080001780 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001780:	c2dd                	beqz	a3,80001826 <copyinstr+0xa6>
{
    80001782:	715d                	add	sp,sp,-80
    80001784:	e486                	sd	ra,72(sp)
    80001786:	e0a2                	sd	s0,64(sp)
    80001788:	fc26                	sd	s1,56(sp)
    8000178a:	f84a                	sd	s2,48(sp)
    8000178c:	f44e                	sd	s3,40(sp)
    8000178e:	f052                	sd	s4,32(sp)
    80001790:	ec56                	sd	s5,24(sp)
    80001792:	e85a                	sd	s6,16(sp)
    80001794:	e45e                	sd	s7,8(sp)
    80001796:	0880                	add	s0,sp,80
    80001798:	8a2a                	mv	s4,a0
    8000179a:	8b2e                	mv	s6,a1
    8000179c:	8bb2                	mv	s7,a2
    8000179e:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a0:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a2:	6985                	lui	s3,0x1
    800017a4:	a02d                	j	800017ce <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017a6:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017aa:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017ac:	37fd                	addw	a5,a5,-1
    800017ae:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b2:	60a6                	ld	ra,72(sp)
    800017b4:	6406                	ld	s0,64(sp)
    800017b6:	74e2                	ld	s1,56(sp)
    800017b8:	7942                	ld	s2,48(sp)
    800017ba:	79a2                	ld	s3,40(sp)
    800017bc:	7a02                	ld	s4,32(sp)
    800017be:	6ae2                	ld	s5,24(sp)
    800017c0:	6b42                	ld	s6,16(sp)
    800017c2:	6ba2                	ld	s7,8(sp)
    800017c4:	6161                	add	sp,sp,80
    800017c6:	8082                	ret
    srcva = va0 + PGSIZE;
    800017c8:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017cc:	c8a9                	beqz	s1,8000181e <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017ce:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d2:	85ca                	mv	a1,s2
    800017d4:	8552                	mv	a0,s4
    800017d6:	00000097          	auipc	ra,0x0
    800017da:	880080e7          	jalr	-1920(ra) # 80001056 <walkaddr>
    if(pa0 == 0)
    800017de:	c131                	beqz	a0,80001822 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017e0:	417906b3          	sub	a3,s2,s7
    800017e4:	96ce                	add	a3,a3,s3
    800017e6:	00d4f363          	bgeu	s1,a3,800017ec <copyinstr+0x6c>
    800017ea:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017ec:	955e                	add	a0,a0,s7
    800017ee:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f2:	daf9                	beqz	a3,800017c8 <copyinstr+0x48>
    800017f4:	87da                	mv	a5,s6
    800017f6:	885a                	mv	a6,s6
      if(*p == '\0'){
    800017f8:	41650633          	sub	a2,a0,s6
    while(n > 0){
    800017fc:	96da                	add	a3,a3,s6
    800017fe:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001800:	00f60733          	add	a4,a2,a5
    80001804:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdc820>
    80001808:	df59                	beqz	a4,800017a6 <copyinstr+0x26>
        *dst = *p;
    8000180a:	00e78023          	sb	a4,0(a5)
      dst++;
    8000180e:	0785                	add	a5,a5,1
    while(n > 0){
    80001810:	fed797e3          	bne	a5,a3,800017fe <copyinstr+0x7e>
    80001814:	14fd                	add	s1,s1,-1
    80001816:	94c2                	add	s1,s1,a6
      --max;
    80001818:	8c8d                	sub	s1,s1,a1
      dst++;
    8000181a:	8b3e                	mv	s6,a5
    8000181c:	b775                	j	800017c8 <copyinstr+0x48>
    8000181e:	4781                	li	a5,0
    80001820:	b771                	j	800017ac <copyinstr+0x2c>
      return -1;
    80001822:	557d                	li	a0,-1
    80001824:	b779                	j	800017b2 <copyinstr+0x32>
  int got_null = 0;
    80001826:	4781                	li	a5,0
  if(got_null){
    80001828:	37fd                	addw	a5,a5,-1
    8000182a:	0007851b          	sext.w	a0,a5
}
    8000182e:	8082                	ret

0000000080001830 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001830:	7139                	add	sp,sp,-64
    80001832:	fc06                	sd	ra,56(sp)
    80001834:	f822                	sd	s0,48(sp)
    80001836:	f426                	sd	s1,40(sp)
    80001838:	f04a                	sd	s2,32(sp)
    8000183a:	ec4e                	sd	s3,24(sp)
    8000183c:	e852                	sd	s4,16(sp)
    8000183e:	e456                	sd	s5,8(sp)
    80001840:	e05a                	sd	s6,0(sp)
    80001842:	0080                	add	s0,sp,64
    80001844:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001846:	00010497          	auipc	s1,0x10
    8000184a:	9ba48493          	add	s1,s1,-1606 # 80011200 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000184e:	8b26                	mv	s6,s1
    80001850:	00006a97          	auipc	s5,0x6
    80001854:	7b0a8a93          	add	s5,s5,1968 # 80008000 <etext>
    80001858:	04000937          	lui	s2,0x4000
    8000185c:	197d                	add	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    8000185e:	0932                	sll	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001860:	00016a17          	auipc	s4,0x16
    80001864:	ba0a0a13          	add	s4,s4,-1120 # 80017400 <tickslock>
    char *pa = kalloc();
    80001868:	fffff097          	auipc	ra,0xfffff
    8000186c:	27a080e7          	jalr	634(ra) # 80000ae2 <kalloc>
    80001870:	862a                	mv	a2,a0
    if(pa == 0)
    80001872:	c131                	beqz	a0,800018b6 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001874:	416485b3          	sub	a1,s1,s6
    80001878:	858d                	sra	a1,a1,0x3
    8000187a:	000ab783          	ld	a5,0(s5)
    8000187e:	02f585b3          	mul	a1,a1,a5
    80001882:	2585                	addw	a1,a1,1
    80001884:	00d5959b          	sllw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001888:	4719                	li	a4,6
    8000188a:	6685                	lui	a3,0x1
    8000188c:	40b905b3          	sub	a1,s2,a1
    80001890:	854e                	mv	a0,s3
    80001892:	00000097          	auipc	ra,0x0
    80001896:	8a6080e7          	jalr	-1882(ra) # 80001138 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000189a:	18848493          	add	s1,s1,392
    8000189e:	fd4495e3          	bne	s1,s4,80001868 <proc_mapstacks+0x38>
  }
}
    800018a2:	70e2                	ld	ra,56(sp)
    800018a4:	7442                	ld	s0,48(sp)
    800018a6:	74a2                	ld	s1,40(sp)
    800018a8:	7902                	ld	s2,32(sp)
    800018aa:	69e2                	ld	s3,24(sp)
    800018ac:	6a42                	ld	s4,16(sp)
    800018ae:	6aa2                	ld	s5,8(sp)
    800018b0:	6b02                	ld	s6,0(sp)
    800018b2:	6121                	add	sp,sp,64
    800018b4:	8082                	ret
      panic("kalloc");
    800018b6:	00007517          	auipc	a0,0x7
    800018ba:	92250513          	add	a0,a0,-1758 # 800081d8 <digits+0x198>
    800018be:	fffff097          	auipc	ra,0xfffff
    800018c2:	c7e080e7          	jalr	-898(ra) # 8000053c <panic>

00000000800018c6 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018c6:	7139                	add	sp,sp,-64
    800018c8:	fc06                	sd	ra,56(sp)
    800018ca:	f822                	sd	s0,48(sp)
    800018cc:	f426                	sd	s1,40(sp)
    800018ce:	f04a                	sd	s2,32(sp)
    800018d0:	ec4e                	sd	s3,24(sp)
    800018d2:	e852                	sd	s4,16(sp)
    800018d4:	e456                	sd	s5,8(sp)
    800018d6:	e05a                	sd	s6,0(sp)
    800018d8:	0080                	add	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018da:	00007597          	auipc	a1,0x7
    800018de:	90658593          	add	a1,a1,-1786 # 800081e0 <digits+0x1a0>
    800018e2:	0000f517          	auipc	a0,0xf
    800018e6:	4ee50513          	add	a0,a0,1262 # 80010dd0 <pid_lock>
    800018ea:	fffff097          	auipc	ra,0xfffff
    800018ee:	258080e7          	jalr	600(ra) # 80000b42 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f2:	00007597          	auipc	a1,0x7
    800018f6:	8f658593          	add	a1,a1,-1802 # 800081e8 <digits+0x1a8>
    800018fa:	0000f517          	auipc	a0,0xf
    800018fe:	4ee50513          	add	a0,a0,1262 # 80010de8 <wait_lock>
    80001902:	fffff097          	auipc	ra,0xfffff
    80001906:	240080e7          	jalr	576(ra) # 80000b42 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000190a:	00010497          	auipc	s1,0x10
    8000190e:	8f648493          	add	s1,s1,-1802 # 80011200 <proc>
      initlock(&p->lock, "proc");
    80001912:	00007b17          	auipc	s6,0x7
    80001916:	8e6b0b13          	add	s6,s6,-1818 # 800081f8 <digits+0x1b8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000191a:	8aa6                	mv	s5,s1
    8000191c:	00006a17          	auipc	s4,0x6
    80001920:	6e4a0a13          	add	s4,s4,1764 # 80008000 <etext>
    80001924:	04000937          	lui	s2,0x4000
    80001928:	197d                	add	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    8000192a:	0932                	sll	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000192c:	00016997          	auipc	s3,0x16
    80001930:	ad498993          	add	s3,s3,-1324 # 80017400 <tickslock>
      initlock(&p->lock, "proc");
    80001934:	85da                	mv	a1,s6
    80001936:	8526                	mv	a0,s1
    80001938:	fffff097          	auipc	ra,0xfffff
    8000193c:	20a080e7          	jalr	522(ra) # 80000b42 <initlock>
      p->state = UNUSED;
    80001940:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001944:	415487b3          	sub	a5,s1,s5
    80001948:	878d                	sra	a5,a5,0x3
    8000194a:	000a3703          	ld	a4,0(s4)
    8000194e:	02e787b3          	mul	a5,a5,a4
    80001952:	2785                	addw	a5,a5,1
    80001954:	00d7979b          	sllw	a5,a5,0xd
    80001958:	40f907b3          	sub	a5,s2,a5
    8000195c:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000195e:	18848493          	add	s1,s1,392
    80001962:	fd3499e3          	bne	s1,s3,80001934 <procinit+0x6e>
  }
}
    80001966:	70e2                	ld	ra,56(sp)
    80001968:	7442                	ld	s0,48(sp)
    8000196a:	74a2                	ld	s1,40(sp)
    8000196c:	7902                	ld	s2,32(sp)
    8000196e:	69e2                	ld	s3,24(sp)
    80001970:	6a42                	ld	s4,16(sp)
    80001972:	6aa2                	ld	s5,8(sp)
    80001974:	6b02                	ld	s6,0(sp)
    80001976:	6121                	add	sp,sp,64
    80001978:	8082                	ret

000000008000197a <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    8000197a:	1141                	add	sp,sp,-16
    8000197c:	e422                	sd	s0,8(sp)
    8000197e:	0800                	add	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001980:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001982:	2501                	sext.w	a0,a0
    80001984:	6422                	ld	s0,8(sp)
    80001986:	0141                	add	sp,sp,16
    80001988:	8082                	ret

000000008000198a <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    8000198a:	1141                	add	sp,sp,-16
    8000198c:	e422                	sd	s0,8(sp)
    8000198e:	0800                	add	s0,sp,16
    80001990:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001992:	2781                	sext.w	a5,a5
    80001994:	079e                	sll	a5,a5,0x7
  return c;
}
    80001996:	0000f517          	auipc	a0,0xf
    8000199a:	46a50513          	add	a0,a0,1130 # 80010e00 <cpus>
    8000199e:	953e                	add	a0,a0,a5
    800019a0:	6422                	ld	s0,8(sp)
    800019a2:	0141                	add	sp,sp,16
    800019a4:	8082                	ret

00000000800019a6 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019a6:	1101                	add	sp,sp,-32
    800019a8:	ec06                	sd	ra,24(sp)
    800019aa:	e822                	sd	s0,16(sp)
    800019ac:	e426                	sd	s1,8(sp)
    800019ae:	1000                	add	s0,sp,32
  push_off();
    800019b0:	fffff097          	auipc	ra,0xfffff
    800019b4:	1d6080e7          	jalr	470(ra) # 80000b86 <push_off>
    800019b8:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019ba:	2781                	sext.w	a5,a5
    800019bc:	079e                	sll	a5,a5,0x7
    800019be:	0000f717          	auipc	a4,0xf
    800019c2:	41270713          	add	a4,a4,1042 # 80010dd0 <pid_lock>
    800019c6:	97ba                	add	a5,a5,a4
    800019c8:	7b84                	ld	s1,48(a5)
  pop_off();
    800019ca:	fffff097          	auipc	ra,0xfffff
    800019ce:	25c080e7          	jalr	604(ra) # 80000c26 <pop_off>
  return p;
}
    800019d2:	8526                	mv	a0,s1
    800019d4:	60e2                	ld	ra,24(sp)
    800019d6:	6442                	ld	s0,16(sp)
    800019d8:	64a2                	ld	s1,8(sp)
    800019da:	6105                	add	sp,sp,32
    800019dc:	8082                	ret

00000000800019de <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019de:	1141                	add	sp,sp,-16
    800019e0:	e406                	sd	ra,8(sp)
    800019e2:	e022                	sd	s0,0(sp)
    800019e4:	0800                	add	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019e6:	00000097          	auipc	ra,0x0
    800019ea:	fc0080e7          	jalr	-64(ra) # 800019a6 <myproc>
    800019ee:	fffff097          	auipc	ra,0xfffff
    800019f2:	298080e7          	jalr	664(ra) # 80000c86 <release>

  if (first) {
    800019f6:	00007797          	auipc	a5,0x7
    800019fa:	fba7a783          	lw	a5,-70(a5) # 800089b0 <first.1>
    800019fe:	eb89                	bnez	a5,80001a10 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a00:	00001097          	auipc	ra,0x1
    80001a04:	ef8080e7          	jalr	-264(ra) # 800028f8 <usertrapret>
}
    80001a08:	60a2                	ld	ra,8(sp)
    80001a0a:	6402                	ld	s0,0(sp)
    80001a0c:	0141                	add	sp,sp,16
    80001a0e:	8082                	ret
    first = 0;
    80001a10:	00007797          	auipc	a5,0x7
    80001a14:	fa07a023          	sw	zero,-96(a5) # 800089b0 <first.1>
    fsinit(ROOTDEV);
    80001a18:	4505                	li	a0,1
    80001a1a:	00002097          	auipc	ra,0x2
    80001a1e:	dfa080e7          	jalr	-518(ra) # 80003814 <fsinit>
    80001a22:	bff9                	j	80001a00 <forkret+0x22>

0000000080001a24 <allocpid>:
{
    80001a24:	1101                	add	sp,sp,-32
    80001a26:	ec06                	sd	ra,24(sp)
    80001a28:	e822                	sd	s0,16(sp)
    80001a2a:	e426                	sd	s1,8(sp)
    80001a2c:	e04a                	sd	s2,0(sp)
    80001a2e:	1000                	add	s0,sp,32
  acquire(&pid_lock);
    80001a30:	0000f917          	auipc	s2,0xf
    80001a34:	3a090913          	add	s2,s2,928 # 80010dd0 <pid_lock>
    80001a38:	854a                	mv	a0,s2
    80001a3a:	fffff097          	auipc	ra,0xfffff
    80001a3e:	198080e7          	jalr	408(ra) # 80000bd2 <acquire>
  pid = nextpid;
    80001a42:	00007797          	auipc	a5,0x7
    80001a46:	f7278793          	add	a5,a5,-142 # 800089b4 <nextpid>
    80001a4a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a4c:	0014871b          	addw	a4,s1,1
    80001a50:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a52:	854a                	mv	a0,s2
    80001a54:	fffff097          	auipc	ra,0xfffff
    80001a58:	232080e7          	jalr	562(ra) # 80000c86 <release>
}
    80001a5c:	8526                	mv	a0,s1
    80001a5e:	60e2                	ld	ra,24(sp)
    80001a60:	6442                	ld	s0,16(sp)
    80001a62:	64a2                	ld	s1,8(sp)
    80001a64:	6902                	ld	s2,0(sp)
    80001a66:	6105                	add	sp,sp,32
    80001a68:	8082                	ret

0000000080001a6a <proc_pagetable>:
{
    80001a6a:	1101                	add	sp,sp,-32
    80001a6c:	ec06                	sd	ra,24(sp)
    80001a6e:	e822                	sd	s0,16(sp)
    80001a70:	e426                	sd	s1,8(sp)
    80001a72:	e04a                	sd	s2,0(sp)
    80001a74:	1000                	add	s0,sp,32
    80001a76:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a78:	00000097          	auipc	ra,0x0
    80001a7c:	8aa080e7          	jalr	-1878(ra) # 80001322 <uvmcreate>
    80001a80:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a82:	c121                	beqz	a0,80001ac2 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a84:	4729                	li	a4,10
    80001a86:	00005697          	auipc	a3,0x5
    80001a8a:	57a68693          	add	a3,a3,1402 # 80007000 <_trampoline>
    80001a8e:	6605                	lui	a2,0x1
    80001a90:	040005b7          	lui	a1,0x4000
    80001a94:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a96:	05b2                	sll	a1,a1,0xc
    80001a98:	fffff097          	auipc	ra,0xfffff
    80001a9c:	600080e7          	jalr	1536(ra) # 80001098 <mappages>
    80001aa0:	02054863          	bltz	a0,80001ad0 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001aa4:	4719                	li	a4,6
    80001aa6:	05893683          	ld	a3,88(s2)
    80001aaa:	6605                	lui	a2,0x1
    80001aac:	020005b7          	lui	a1,0x2000
    80001ab0:	15fd                	add	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ab2:	05b6                	sll	a1,a1,0xd
    80001ab4:	8526                	mv	a0,s1
    80001ab6:	fffff097          	auipc	ra,0xfffff
    80001aba:	5e2080e7          	jalr	1506(ra) # 80001098 <mappages>
    80001abe:	02054163          	bltz	a0,80001ae0 <proc_pagetable+0x76>
}
    80001ac2:	8526                	mv	a0,s1
    80001ac4:	60e2                	ld	ra,24(sp)
    80001ac6:	6442                	ld	s0,16(sp)
    80001ac8:	64a2                	ld	s1,8(sp)
    80001aca:	6902                	ld	s2,0(sp)
    80001acc:	6105                	add	sp,sp,32
    80001ace:	8082                	ret
    uvmfree(pagetable, 0);
    80001ad0:	4581                	li	a1,0
    80001ad2:	8526                	mv	a0,s1
    80001ad4:	00000097          	auipc	ra,0x0
    80001ad8:	a54080e7          	jalr	-1452(ra) # 80001528 <uvmfree>
    return 0;
    80001adc:	4481                	li	s1,0
    80001ade:	b7d5                	j	80001ac2 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ae0:	4681                	li	a3,0
    80001ae2:	4605                	li	a2,1
    80001ae4:	040005b7          	lui	a1,0x4000
    80001ae8:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001aea:	05b2                	sll	a1,a1,0xc
    80001aec:	8526                	mv	a0,s1
    80001aee:	fffff097          	auipc	ra,0xfffff
    80001af2:	770080e7          	jalr	1904(ra) # 8000125e <uvmunmap>
    uvmfree(pagetable, 0);
    80001af6:	4581                	li	a1,0
    80001af8:	8526                	mv	a0,s1
    80001afa:	00000097          	auipc	ra,0x0
    80001afe:	a2e080e7          	jalr	-1490(ra) # 80001528 <uvmfree>
    return 0;
    80001b02:	4481                	li	s1,0
    80001b04:	bf7d                	j	80001ac2 <proc_pagetable+0x58>

0000000080001b06 <proc_freepagetable>:
{
    80001b06:	1101                	add	sp,sp,-32
    80001b08:	ec06                	sd	ra,24(sp)
    80001b0a:	e822                	sd	s0,16(sp)
    80001b0c:	e426                	sd	s1,8(sp)
    80001b0e:	e04a                	sd	s2,0(sp)
    80001b10:	1000                	add	s0,sp,32
    80001b12:	84aa                	mv	s1,a0
    80001b14:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b16:	4681                	li	a3,0
    80001b18:	4605                	li	a2,1
    80001b1a:	040005b7          	lui	a1,0x4000
    80001b1e:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b20:	05b2                	sll	a1,a1,0xc
    80001b22:	fffff097          	auipc	ra,0xfffff
    80001b26:	73c080e7          	jalr	1852(ra) # 8000125e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b2a:	4681                	li	a3,0
    80001b2c:	4605                	li	a2,1
    80001b2e:	020005b7          	lui	a1,0x2000
    80001b32:	15fd                	add	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b34:	05b6                	sll	a1,a1,0xd
    80001b36:	8526                	mv	a0,s1
    80001b38:	fffff097          	auipc	ra,0xfffff
    80001b3c:	726080e7          	jalr	1830(ra) # 8000125e <uvmunmap>
  uvmfree(pagetable, sz);
    80001b40:	85ca                	mv	a1,s2
    80001b42:	8526                	mv	a0,s1
    80001b44:	00000097          	auipc	ra,0x0
    80001b48:	9e4080e7          	jalr	-1564(ra) # 80001528 <uvmfree>
}
    80001b4c:	60e2                	ld	ra,24(sp)
    80001b4e:	6442                	ld	s0,16(sp)
    80001b50:	64a2                	ld	s1,8(sp)
    80001b52:	6902                	ld	s2,0(sp)
    80001b54:	6105                	add	sp,sp,32
    80001b56:	8082                	ret

0000000080001b58 <freeproc>:
{
    80001b58:	1101                	add	sp,sp,-32
    80001b5a:	ec06                	sd	ra,24(sp)
    80001b5c:	e822                	sd	s0,16(sp)
    80001b5e:	e426                	sd	s1,8(sp)
    80001b60:	1000                	add	s0,sp,32
    80001b62:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b64:	6d28                	ld	a0,88(a0)
    80001b66:	c509                	beqz	a0,80001b70 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b68:	fffff097          	auipc	ra,0xfffff
    80001b6c:	e7c080e7          	jalr	-388(ra) # 800009e4 <kfree>
  p->trapframe = 0;
    80001b70:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b74:	68a8                	ld	a0,80(s1)
    80001b76:	c511                	beqz	a0,80001b82 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b78:	64ac                	ld	a1,72(s1)
    80001b7a:	00000097          	auipc	ra,0x0
    80001b7e:	f8c080e7          	jalr	-116(ra) # 80001b06 <proc_freepagetable>
  p->pagetable = 0;
    80001b82:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b86:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b8a:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b8e:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b92:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b96:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b9a:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b9e:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001ba2:	0004ac23          	sw	zero,24(s1)
}
    80001ba6:	60e2                	ld	ra,24(sp)
    80001ba8:	6442                	ld	s0,16(sp)
    80001baa:	64a2                	ld	s1,8(sp)
    80001bac:	6105                	add	sp,sp,32
    80001bae:	8082                	ret

0000000080001bb0 <allocproc>:
{
    80001bb0:	1101                	add	sp,sp,-32
    80001bb2:	ec06                	sd	ra,24(sp)
    80001bb4:	e822                	sd	s0,16(sp)
    80001bb6:	e426                	sd	s1,8(sp)
    80001bb8:	e04a                	sd	s2,0(sp)
    80001bba:	1000                	add	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bbc:	0000f497          	auipc	s1,0xf
    80001bc0:	64448493          	add	s1,s1,1604 # 80011200 <proc>
    80001bc4:	00016917          	auipc	s2,0x16
    80001bc8:	83c90913          	add	s2,s2,-1988 # 80017400 <tickslock>
    acquire(&p->lock);
    80001bcc:	8526                	mv	a0,s1
    80001bce:	fffff097          	auipc	ra,0xfffff
    80001bd2:	004080e7          	jalr	4(ra) # 80000bd2 <acquire>
    if(p->state == UNUSED) {
    80001bd6:	4c9c                	lw	a5,24(s1)
    80001bd8:	cf81                	beqz	a5,80001bf0 <allocproc+0x40>
      release(&p->lock);
    80001bda:	8526                	mv	a0,s1
    80001bdc:	fffff097          	auipc	ra,0xfffff
    80001be0:	0aa080e7          	jalr	170(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001be4:	18848493          	add	s1,s1,392
    80001be8:	ff2492e3          	bne	s1,s2,80001bcc <allocproc+0x1c>
  return 0;
    80001bec:	4481                	li	s1,0
    80001bee:	a0bd                	j	80001c5c <allocproc+0xac>
  p->pid = allocpid();
    80001bf0:	00000097          	auipc	ra,0x0
    80001bf4:	e34080e7          	jalr	-460(ra) # 80001a24 <allocpid>
    80001bf8:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001bfa:	4785                	li	a5,1
    80001bfc:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001bfe:	fffff097          	auipc	ra,0xfffff
    80001c02:	ee4080e7          	jalr	-284(ra) # 80000ae2 <kalloc>
    80001c06:	892a                	mv	s2,a0
    80001c08:	eca8                	sd	a0,88(s1)
    80001c0a:	c125                	beqz	a0,80001c6a <allocproc+0xba>
  p->pagetable = proc_pagetable(p);
    80001c0c:	8526                	mv	a0,s1
    80001c0e:	00000097          	auipc	ra,0x0
    80001c12:	e5c080e7          	jalr	-420(ra) # 80001a6a <proc_pagetable>
    80001c16:	892a                	mv	s2,a0
    80001c18:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c1a:	c525                	beqz	a0,80001c82 <allocproc+0xd2>
  memset(&p->context, 0, sizeof(p->context));
    80001c1c:	07000613          	li	a2,112
    80001c20:	4581                	li	a1,0
    80001c22:	06048513          	add	a0,s1,96
    80001c26:	fffff097          	auipc	ra,0xfffff
    80001c2a:	0a8080e7          	jalr	168(ra) # 80000cce <memset>
  p->context.ra = (uint64)forkret;
    80001c2e:	00000797          	auipc	a5,0x0
    80001c32:	db078793          	add	a5,a5,-592 # 800019de <forkret>
    80001c36:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c38:	60bc                	ld	a5,64(s1)
    80001c3a:	6705                	lui	a4,0x1
    80001c3c:	97ba                	add	a5,a5,a4
    80001c3e:	f4bc                	sd	a5,104(s1)
  	  p->rtime = 0;	
    80001c40:	1604ac23          	sw	zero,376(s1)
  p->etime = 0;	
    80001c44:	1804a023          	sw	zero,384(s1)
  p->ctime = ticks;	
    80001c48:	00007797          	auipc	a5,0x7
    80001c4c:	f187a783          	lw	a5,-232(a5) # 80008b60 <ticks>
    80001c50:	16f4ae23          	sw	a5,380(s1)
  p->mask = 0;	
    80001c54:	1604a423          	sw	zero,360(s1)
  p->no_of_times_scheduled = 0;	
    80001c58:	1804a223          	sw	zero,388(s1)
}
    80001c5c:	8526                	mv	a0,s1
    80001c5e:	60e2                	ld	ra,24(sp)
    80001c60:	6442                	ld	s0,16(sp)
    80001c62:	64a2                	ld	s1,8(sp)
    80001c64:	6902                	ld	s2,0(sp)
    80001c66:	6105                	add	sp,sp,32
    80001c68:	8082                	ret
    freeproc(p);
    80001c6a:	8526                	mv	a0,s1
    80001c6c:	00000097          	auipc	ra,0x0
    80001c70:	eec080e7          	jalr	-276(ra) # 80001b58 <freeproc>
    release(&p->lock);
    80001c74:	8526                	mv	a0,s1
    80001c76:	fffff097          	auipc	ra,0xfffff
    80001c7a:	010080e7          	jalr	16(ra) # 80000c86 <release>
    return 0;
    80001c7e:	84ca                	mv	s1,s2
    80001c80:	bff1                	j	80001c5c <allocproc+0xac>
    freeproc(p);
    80001c82:	8526                	mv	a0,s1
    80001c84:	00000097          	auipc	ra,0x0
    80001c88:	ed4080e7          	jalr	-300(ra) # 80001b58 <freeproc>
    release(&p->lock);
    80001c8c:	8526                	mv	a0,s1
    80001c8e:	fffff097          	auipc	ra,0xfffff
    80001c92:	ff8080e7          	jalr	-8(ra) # 80000c86 <release>
    return 0;
    80001c96:	84ca                	mv	s1,s2
    80001c98:	b7d1                	j	80001c5c <allocproc+0xac>

0000000080001c9a <userinit>:
{
    80001c9a:	1101                	add	sp,sp,-32
    80001c9c:	ec06                	sd	ra,24(sp)
    80001c9e:	e822                	sd	s0,16(sp)
    80001ca0:	e426                	sd	s1,8(sp)
    80001ca2:	1000                	add	s0,sp,32
  p = allocproc();
    80001ca4:	00000097          	auipc	ra,0x0
    80001ca8:	f0c080e7          	jalr	-244(ra) # 80001bb0 <allocproc>
    80001cac:	84aa                	mv	s1,a0
  initproc = p;
    80001cae:	00007797          	auipc	a5,0x7
    80001cb2:	eaa7b523          	sd	a0,-342(a5) # 80008b58 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001cb6:	03400613          	li	a2,52
    80001cba:	00007597          	auipc	a1,0x7
    80001cbe:	d0658593          	add	a1,a1,-762 # 800089c0 <initcode>
    80001cc2:	6928                	ld	a0,80(a0)
    80001cc4:	fffff097          	auipc	ra,0xfffff
    80001cc8:	68c080e7          	jalr	1676(ra) # 80001350 <uvmfirst>
  p->sz = PGSIZE;
    80001ccc:	6785                	lui	a5,0x1
    80001cce:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cd0:	6cb8                	ld	a4,88(s1)
    80001cd2:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cd6:	6cb8                	ld	a4,88(s1)
    80001cd8:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cda:	4641                	li	a2,16
    80001cdc:	00006597          	auipc	a1,0x6
    80001ce0:	52458593          	add	a1,a1,1316 # 80008200 <digits+0x1c0>
    80001ce4:	15848513          	add	a0,s1,344
    80001ce8:	fffff097          	auipc	ra,0xfffff
    80001cec:	12e080e7          	jalr	302(ra) # 80000e16 <safestrcpy>
  p->cwd = namei("/");
    80001cf0:	00006517          	auipc	a0,0x6
    80001cf4:	52050513          	add	a0,a0,1312 # 80008210 <digits+0x1d0>
    80001cf8:	00002097          	auipc	ra,0x2
    80001cfc:	53a080e7          	jalr	1338(ra) # 80004232 <namei>
    80001d00:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d04:	478d                	li	a5,3
    80001d06:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d08:	8526                	mv	a0,s1
    80001d0a:	fffff097          	auipc	ra,0xfffff
    80001d0e:	f7c080e7          	jalr	-132(ra) # 80000c86 <release>
}
    80001d12:	60e2                	ld	ra,24(sp)
    80001d14:	6442                	ld	s0,16(sp)
    80001d16:	64a2                	ld	s1,8(sp)
    80001d18:	6105                	add	sp,sp,32
    80001d1a:	8082                	ret

0000000080001d1c <growproc>:
{
    80001d1c:	1101                	add	sp,sp,-32
    80001d1e:	ec06                	sd	ra,24(sp)
    80001d20:	e822                	sd	s0,16(sp)
    80001d22:	e426                	sd	s1,8(sp)
    80001d24:	e04a                	sd	s2,0(sp)
    80001d26:	1000                	add	s0,sp,32
    80001d28:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d2a:	00000097          	auipc	ra,0x0
    80001d2e:	c7c080e7          	jalr	-900(ra) # 800019a6 <myproc>
    80001d32:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d34:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d36:	01204c63          	bgtz	s2,80001d4e <growproc+0x32>
  } else if(n < 0){
    80001d3a:	02094663          	bltz	s2,80001d66 <growproc+0x4a>
  p->sz = sz;
    80001d3e:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d40:	4501                	li	a0,0
}
    80001d42:	60e2                	ld	ra,24(sp)
    80001d44:	6442                	ld	s0,16(sp)
    80001d46:	64a2                	ld	s1,8(sp)
    80001d48:	6902                	ld	s2,0(sp)
    80001d4a:	6105                	add	sp,sp,32
    80001d4c:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d4e:	4691                	li	a3,4
    80001d50:	00b90633          	add	a2,s2,a1
    80001d54:	6928                	ld	a0,80(a0)
    80001d56:	fffff097          	auipc	ra,0xfffff
    80001d5a:	6b4080e7          	jalr	1716(ra) # 8000140a <uvmalloc>
    80001d5e:	85aa                	mv	a1,a0
    80001d60:	fd79                	bnez	a0,80001d3e <growproc+0x22>
      return -1;
    80001d62:	557d                	li	a0,-1
    80001d64:	bff9                	j	80001d42 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d66:	00b90633          	add	a2,s2,a1
    80001d6a:	6928                	ld	a0,80(a0)
    80001d6c:	fffff097          	auipc	ra,0xfffff
    80001d70:	656080e7          	jalr	1622(ra) # 800013c2 <uvmdealloc>
    80001d74:	85aa                	mv	a1,a0
    80001d76:	b7e1                	j	80001d3e <growproc+0x22>

0000000080001d78 <fork>:
{
    80001d78:	7139                	add	sp,sp,-64
    80001d7a:	fc06                	sd	ra,56(sp)
    80001d7c:	f822                	sd	s0,48(sp)
    80001d7e:	f426                	sd	s1,40(sp)
    80001d80:	f04a                	sd	s2,32(sp)
    80001d82:	ec4e                	sd	s3,24(sp)
    80001d84:	e852                	sd	s4,16(sp)
    80001d86:	e456                	sd	s5,8(sp)
    80001d88:	0080                	add	s0,sp,64
  struct proc *p = myproc();
    80001d8a:	00000097          	auipc	ra,0x0
    80001d8e:	c1c080e7          	jalr	-996(ra) # 800019a6 <myproc>
    80001d92:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001d94:	00000097          	auipc	ra,0x0
    80001d98:	e1c080e7          	jalr	-484(ra) # 80001bb0 <allocproc>
    80001d9c:	12050063          	beqz	a0,80001ebc <fork+0x144>
    80001da0:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001da2:	048ab603          	ld	a2,72(s5)
    80001da6:	692c                	ld	a1,80(a0)
    80001da8:	050ab503          	ld	a0,80(s5)
    80001dac:	fffff097          	auipc	ra,0xfffff
    80001db0:	7b6080e7          	jalr	1974(ra) # 80001562 <uvmcopy>
    80001db4:	04054c63          	bltz	a0,80001e0c <fork+0x94>
  np->sz = p->sz;
    80001db8:	048ab783          	ld	a5,72(s5)
    80001dbc:	04f9b423          	sd	a5,72(s3)
  np->mask = p->mask; // strace sys call
    80001dc0:	168aa783          	lw	a5,360(s5)
    80001dc4:	16f9a423          	sw	a5,360(s3)
  *(np->trapframe) = *(p->trapframe);
    80001dc8:	058ab683          	ld	a3,88(s5)
    80001dcc:	87b6                	mv	a5,a3
    80001dce:	0589b703          	ld	a4,88(s3)
    80001dd2:	12068693          	add	a3,a3,288
    80001dd6:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001dda:	6788                	ld	a0,8(a5)
    80001ddc:	6b8c                	ld	a1,16(a5)
    80001dde:	6f90                	ld	a2,24(a5)
    80001de0:	01073023          	sd	a6,0(a4)
    80001de4:	e708                	sd	a0,8(a4)
    80001de6:	eb0c                	sd	a1,16(a4)
    80001de8:	ef10                	sd	a2,24(a4)
    80001dea:	02078793          	add	a5,a5,32
    80001dee:	02070713          	add	a4,a4,32
    80001df2:	fed792e3          	bne	a5,a3,80001dd6 <fork+0x5e>
  np->trapframe->a0 = 0;
    80001df6:	0589b783          	ld	a5,88(s3)
    80001dfa:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001dfe:	0d0a8493          	add	s1,s5,208
    80001e02:	0d098913          	add	s2,s3,208
    80001e06:	150a8a13          	add	s4,s5,336
    80001e0a:	a00d                	j	80001e2c <fork+0xb4>
    freeproc(np);
    80001e0c:	854e                	mv	a0,s3
    80001e0e:	00000097          	auipc	ra,0x0
    80001e12:	d4a080e7          	jalr	-694(ra) # 80001b58 <freeproc>
    release(&np->lock);
    80001e16:	854e                	mv	a0,s3
    80001e18:	fffff097          	auipc	ra,0xfffff
    80001e1c:	e6e080e7          	jalr	-402(ra) # 80000c86 <release>
    return -1;
    80001e20:	597d                	li	s2,-1
    80001e22:	a059                	j	80001ea8 <fork+0x130>
  for(i = 0; i < NOFILE; i++)
    80001e24:	04a1                	add	s1,s1,8
    80001e26:	0921                	add	s2,s2,8
    80001e28:	01448b63          	beq	s1,s4,80001e3e <fork+0xc6>
    if(p->ofile[i])
    80001e2c:	6088                	ld	a0,0(s1)
    80001e2e:	d97d                	beqz	a0,80001e24 <fork+0xac>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e30:	00003097          	auipc	ra,0x3
    80001e34:	a74080e7          	jalr	-1420(ra) # 800048a4 <filedup>
    80001e38:	00a93023          	sd	a0,0(s2)
    80001e3c:	b7e5                	j	80001e24 <fork+0xac>
  np->cwd = idup(p->cwd);
    80001e3e:	150ab503          	ld	a0,336(s5)
    80001e42:	00002097          	auipc	ra,0x2
    80001e46:	c0c080e7          	jalr	-1012(ra) # 80003a4e <idup>
    80001e4a:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e4e:	4641                	li	a2,16
    80001e50:	158a8593          	add	a1,s5,344
    80001e54:	15898513          	add	a0,s3,344
    80001e58:	fffff097          	auipc	ra,0xfffff
    80001e5c:	fbe080e7          	jalr	-66(ra) # 80000e16 <safestrcpy>
  pid = np->pid;
    80001e60:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001e64:	854e                	mv	a0,s3
    80001e66:	fffff097          	auipc	ra,0xfffff
    80001e6a:	e20080e7          	jalr	-480(ra) # 80000c86 <release>
  acquire(&wait_lock);
    80001e6e:	0000f497          	auipc	s1,0xf
    80001e72:	f7a48493          	add	s1,s1,-134 # 80010de8 <wait_lock>
    80001e76:	8526                	mv	a0,s1
    80001e78:	fffff097          	auipc	ra,0xfffff
    80001e7c:	d5a080e7          	jalr	-678(ra) # 80000bd2 <acquire>
  np->parent = p;
    80001e80:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001e84:	8526                	mv	a0,s1
    80001e86:	fffff097          	auipc	ra,0xfffff
    80001e8a:	e00080e7          	jalr	-512(ra) # 80000c86 <release>
  acquire(&np->lock);
    80001e8e:	854e                	mv	a0,s3
    80001e90:	fffff097          	auipc	ra,0xfffff
    80001e94:	d42080e7          	jalr	-702(ra) # 80000bd2 <acquire>
  np->state = RUNNABLE;
    80001e98:	478d                	li	a5,3
    80001e9a:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001e9e:	854e                	mv	a0,s3
    80001ea0:	fffff097          	auipc	ra,0xfffff
    80001ea4:	de6080e7          	jalr	-538(ra) # 80000c86 <release>
}
    80001ea8:	854a                	mv	a0,s2
    80001eaa:	70e2                	ld	ra,56(sp)
    80001eac:	7442                	ld	s0,48(sp)
    80001eae:	74a2                	ld	s1,40(sp)
    80001eb0:	7902                	ld	s2,32(sp)
    80001eb2:	69e2                	ld	s3,24(sp)
    80001eb4:	6a42                	ld	s4,16(sp)
    80001eb6:	6aa2                	ld	s5,8(sp)
    80001eb8:	6121                	add	sp,sp,64
    80001eba:	8082                	ret
    return -1;
    80001ebc:	597d                	li	s2,-1
    80001ebe:	b7ed                	j	80001ea8 <fork+0x130>

0000000080001ec0 <update_time>:
{	
    80001ec0:	7179                	add	sp,sp,-48
    80001ec2:	f406                	sd	ra,40(sp)
    80001ec4:	f022                	sd	s0,32(sp)
    80001ec6:	ec26                	sd	s1,24(sp)
    80001ec8:	e84a                	sd	s2,16(sp)
    80001eca:	e44e                	sd	s3,8(sp)
    80001ecc:	1800                	add	s0,sp,48
  for (p = proc; p < &proc[NPROC]; p++) {	
    80001ece:	0000f497          	auipc	s1,0xf
    80001ed2:	33248493          	add	s1,s1,818 # 80011200 <proc>
    if (p->state == RUNNING) {	
    80001ed6:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++) {	
    80001ed8:	00015917          	auipc	s2,0x15
    80001edc:	52890913          	add	s2,s2,1320 # 80017400 <tickslock>
    80001ee0:	a811                	j	80001ef4 <update_time+0x34>
    release(&p->lock); 	
    80001ee2:	8526                	mv	a0,s1
    80001ee4:	fffff097          	auipc	ra,0xfffff
    80001ee8:	da2080e7          	jalr	-606(ra) # 80000c86 <release>
  for (p = proc; p < &proc[NPROC]; p++) {	
    80001eec:	18848493          	add	s1,s1,392
    80001ef0:	03248063          	beq	s1,s2,80001f10 <update_time+0x50>
    acquire(&p->lock);	
    80001ef4:	8526                	mv	a0,s1
    80001ef6:	fffff097          	auipc	ra,0xfffff
    80001efa:	cdc080e7          	jalr	-804(ra) # 80000bd2 <acquire>
    if (p->state == RUNNING) {	
    80001efe:	4c9c                	lw	a5,24(s1)
    80001f00:	ff3791e3          	bne	a5,s3,80001ee2 <update_time+0x22>
      p->rtime++;	
    80001f04:	1784a783          	lw	a5,376(s1)
    80001f08:	2785                	addw	a5,a5,1
    80001f0a:	16f4ac23          	sw	a5,376(s1)
    80001f0e:	bfd1                	j	80001ee2 <update_time+0x22>
}	
    80001f10:	70a2                	ld	ra,40(sp)
    80001f12:	7402                	ld	s0,32(sp)
    80001f14:	64e2                	ld	s1,24(sp)
    80001f16:	6942                	ld	s2,16(sp)
    80001f18:	69a2                	ld	s3,8(sp)
    80001f1a:	6145                	add	sp,sp,48
    80001f1c:	8082                	ret

0000000080001f1e <trace>:
{	
    80001f1e:	1101                	add	sp,sp,-32
    80001f20:	ec06                	sd	ra,24(sp)
    80001f22:	e822                	sd	s0,16(sp)
    80001f24:	e426                	sd	s1,8(sp)
    80001f26:	e04a                	sd	s2,0(sp)
    80001f28:	1000                	add	s0,sp,32
    80001f2a:	892a                	mv	s2,a0
  struct proc *p = myproc();	
    80001f2c:	00000097          	auipc	ra,0x0
    80001f30:	a7a080e7          	jalr	-1414(ra) # 800019a6 <myproc>
    80001f34:	84aa                	mv	s1,a0
  acquire(&p->lock);	
    80001f36:	fffff097          	auipc	ra,0xfffff
    80001f3a:	c9c080e7          	jalr	-868(ra) # 80000bd2 <acquire>
  p->mask = mask;	
    80001f3e:	1724a423          	sw	s2,360(s1)
  release(&p->lock);	
    80001f42:	8526                	mv	a0,s1
    80001f44:	fffff097          	auipc	ra,0xfffff
    80001f48:	d42080e7          	jalr	-702(ra) # 80000c86 <release>
}	
    80001f4c:	60e2                	ld	ra,24(sp)
    80001f4e:	6442                	ld	s0,16(sp)
    80001f50:	64a2                	ld	s1,8(sp)
    80001f52:	6902                	ld	s2,0(sp)
    80001f54:	6105                	add	sp,sp,32
    80001f56:	8082                	ret

0000000080001f58 <set_priority>:
{	
    80001f58:	1141                	add	sp,sp,-16
    80001f5a:	e422                	sd	s0,8(sp)
    80001f5c:	0800                	add	s0,sp,16
    80001f5e:	04000793          	li	a5,64
  for (p = proc; p < &proc[NPROC]; p++) {	
    80001f62:	17fd                	add	a5,a5,-1
    80001f64:	fffd                	bnez	a5,80001f62 <set_priority+0xa>
}
    80001f66:	557d                	li	a0,-1
    80001f68:	6422                	ld	s0,8(sp)
    80001f6a:	0141                	add	sp,sp,16
    80001f6c:	8082                	ret

0000000080001f6e <scheduler>:
{
    80001f6e:	715d                	add	sp,sp,-80
    80001f70:	e486                	sd	ra,72(sp)
    80001f72:	e0a2                	sd	s0,64(sp)
    80001f74:	fc26                	sd	s1,56(sp)
    80001f76:	f84a                	sd	s2,48(sp)
    80001f78:	f44e                	sd	s3,40(sp)
    80001f7a:	f052                	sd	s4,32(sp)
    80001f7c:	ec56                	sd	s5,24(sp)
    80001f7e:	e85a                	sd	s6,16(sp)
    80001f80:	e45e                	sd	s7,8(sp)
    80001f82:	0880                	add	s0,sp,80
    80001f84:	8792                	mv	a5,tp
  int id = r_tp();
    80001f86:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f88:	00779693          	sll	a3,a5,0x7
    80001f8c:	0000f717          	auipc	a4,0xf
    80001f90:	e4470713          	add	a4,a4,-444 # 80010dd0 <pid_lock>
    80001f94:	9736                	add	a4,a4,a3
    80001f96:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &minProc->context);	
    80001f9a:	0000f717          	auipc	a4,0xf
    80001f9e:	e6e70713          	add	a4,a4,-402 # 80010e08 <cpus+0x8>
    80001fa2:	00e68b33          	add	s6,a3,a4
    struct proc *minProc = 0;	
    80001fa6:	4a01                	li	s4,0
      if (p->state == RUNNABLE) {	
    80001fa8:	448d                	li	s1,3
    for (p = proc; p < &proc[NPROC]; p++) {	
    80001faa:	00015917          	auipc	s2,0x15
    80001fae:	45690913          	add	s2,s2,1110 # 80017400 <tickslock>
        c->proc = minProc;	
    80001fb2:	0000fa97          	auipc	s5,0xf
    80001fb6:	e1ea8a93          	add	s5,s5,-482 # 80010dd0 <pid_lock>
    80001fba:	9ab6                	add	s5,s5,a3
    80001fbc:	a035                	j	80001fe8 <scheduler+0x7a>
        if (minProc == 0)	
    80001fbe:	08098463          	beqz	s3,80002046 <scheduler+0xd8>
        else if (minProc->ctime > p->ctime)	
    80001fc2:	17c9a683          	lw	a3,380(s3)
    80001fc6:	17c7a703          	lw	a4,380(a5)
    80001fca:	08d76063          	bltu	a4,a3,8000204a <scheduler+0xdc>
    for (p = proc; p < &proc[NPROC]; p++) {	
    80001fce:	18878793          	add	a5,a5,392
    80001fd2:	03278763          	beq	a5,s2,80002000 <scheduler+0x92>
      if (p->state == RUNNABLE) {	
    80001fd6:	4f98                	lw	a4,24(a5)
    80001fd8:	fe9703e3          	beq	a4,s1,80001fbe <scheduler+0x50>
    for (p = proc; p < &proc[NPROC]; p++) {	
    80001fdc:	18878793          	add	a5,a5,392
    80001fe0:	ff279be3          	bne	a5,s2,80001fd6 <scheduler+0x68>
    if (minProc != 0) {	
    80001fe4:	00099e63          	bnez	s3,80002000 <scheduler+0x92>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fe8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fec:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ff0:	10079073          	csrw	sstatus,a5
    struct proc *minProc = 0;	
    80001ff4:	89d2                	mv	s3,s4
    for (p = proc; p < &proc[NPROC]; p++) {	
    80001ff6:	0000f797          	auipc	a5,0xf
    80001ffa:	20a78793          	add	a5,a5,522 # 80011200 <proc>
    80001ffe:	bfe1                	j	80001fd6 <scheduler+0x68>
      acquire(&minProc->lock);	
    80002000:	8bce                	mv	s7,s3
    80002002:	854e                	mv	a0,s3
    80002004:	fffff097          	auipc	ra,0xfffff
    80002008:	bce080e7          	jalr	-1074(ra) # 80000bd2 <acquire>
      if (minProc->state == RUNNABLE) {	
    8000200c:	0189a783          	lw	a5,24(s3)
    80002010:	02979563          	bne	a5,s1,8000203a <scheduler+0xcc>
        minProc->no_of_times_scheduled++;	
    80002014:	1849a783          	lw	a5,388(s3)
    80002018:	2785                	addw	a5,a5,1
    8000201a:	18f9a223          	sw	a5,388(s3)
        minProc->state = RUNNING;	
    8000201e:	4791                	li	a5,4
    80002020:	00f9ac23          	sw	a5,24(s3)
        c->proc = minProc;	
    80002024:	033ab823          	sd	s3,48(s5)
        swtch(&c->context, &minProc->context);	
    80002028:	06098593          	add	a1,s3,96
    8000202c:	855a                	mv	a0,s6
    8000202e:	00001097          	auipc	ra,0x1
    80002032:	820080e7          	jalr	-2016(ra) # 8000284e <swtch>
        c->proc = 0;	
    80002036:	020ab823          	sd	zero,48(s5)
      release(&minProc->lock);	
    8000203a:	855e                	mv	a0,s7
    8000203c:	fffff097          	auipc	ra,0xfffff
    80002040:	c4a080e7          	jalr	-950(ra) # 80000c86 <release>
    80002044:	b755                	j	80001fe8 <scheduler+0x7a>
    80002046:	89be                	mv	s3,a5
    80002048:	b759                	j	80001fce <scheduler+0x60>
    8000204a:	89be                	mv	s3,a5
    8000204c:	b749                	j	80001fce <scheduler+0x60>

000000008000204e <sched>:
{
    8000204e:	7179                	add	sp,sp,-48
    80002050:	f406                	sd	ra,40(sp)
    80002052:	f022                	sd	s0,32(sp)
    80002054:	ec26                	sd	s1,24(sp)
    80002056:	e84a                	sd	s2,16(sp)
    80002058:	e44e                	sd	s3,8(sp)
    8000205a:	1800                	add	s0,sp,48
  struct proc *p = myproc();
    8000205c:	00000097          	auipc	ra,0x0
    80002060:	94a080e7          	jalr	-1718(ra) # 800019a6 <myproc>
    80002064:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002066:	fffff097          	auipc	ra,0xfffff
    8000206a:	af2080e7          	jalr	-1294(ra) # 80000b58 <holding>
    8000206e:	c93d                	beqz	a0,800020e4 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002070:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002072:	2781                	sext.w	a5,a5
    80002074:	079e                	sll	a5,a5,0x7
    80002076:	0000f717          	auipc	a4,0xf
    8000207a:	d5a70713          	add	a4,a4,-678 # 80010dd0 <pid_lock>
    8000207e:	97ba                	add	a5,a5,a4
    80002080:	0a87a703          	lw	a4,168(a5)
    80002084:	4785                	li	a5,1
    80002086:	06f71763          	bne	a4,a5,800020f4 <sched+0xa6>
  if(p->state == RUNNING)
    8000208a:	4c98                	lw	a4,24(s1)
    8000208c:	4791                	li	a5,4
    8000208e:	06f70b63          	beq	a4,a5,80002104 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002092:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002096:	8b89                	and	a5,a5,2
  if(intr_get())
    80002098:	efb5                	bnez	a5,80002114 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000209a:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000209c:	0000f917          	auipc	s2,0xf
    800020a0:	d3490913          	add	s2,s2,-716 # 80010dd0 <pid_lock>
    800020a4:	2781                	sext.w	a5,a5
    800020a6:	079e                	sll	a5,a5,0x7
    800020a8:	97ca                	add	a5,a5,s2
    800020aa:	0ac7a983          	lw	s3,172(a5)
    800020ae:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800020b0:	2781                	sext.w	a5,a5
    800020b2:	079e                	sll	a5,a5,0x7
    800020b4:	0000f597          	auipc	a1,0xf
    800020b8:	d5458593          	add	a1,a1,-684 # 80010e08 <cpus+0x8>
    800020bc:	95be                	add	a1,a1,a5
    800020be:	06048513          	add	a0,s1,96
    800020c2:	00000097          	auipc	ra,0x0
    800020c6:	78c080e7          	jalr	1932(ra) # 8000284e <swtch>
    800020ca:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020cc:	2781                	sext.w	a5,a5
    800020ce:	079e                	sll	a5,a5,0x7
    800020d0:	993e                	add	s2,s2,a5
    800020d2:	0b392623          	sw	s3,172(s2)
}
    800020d6:	70a2                	ld	ra,40(sp)
    800020d8:	7402                	ld	s0,32(sp)
    800020da:	64e2                	ld	s1,24(sp)
    800020dc:	6942                	ld	s2,16(sp)
    800020de:	69a2                	ld	s3,8(sp)
    800020e0:	6145                	add	sp,sp,48
    800020e2:	8082                	ret
    panic("sched p->lock");
    800020e4:	00006517          	auipc	a0,0x6
    800020e8:	13450513          	add	a0,a0,308 # 80008218 <digits+0x1d8>
    800020ec:	ffffe097          	auipc	ra,0xffffe
    800020f0:	450080e7          	jalr	1104(ra) # 8000053c <panic>
    panic("sched locks");
    800020f4:	00006517          	auipc	a0,0x6
    800020f8:	13450513          	add	a0,a0,308 # 80008228 <digits+0x1e8>
    800020fc:	ffffe097          	auipc	ra,0xffffe
    80002100:	440080e7          	jalr	1088(ra) # 8000053c <panic>
    panic("sched running");
    80002104:	00006517          	auipc	a0,0x6
    80002108:	13450513          	add	a0,a0,308 # 80008238 <digits+0x1f8>
    8000210c:	ffffe097          	auipc	ra,0xffffe
    80002110:	430080e7          	jalr	1072(ra) # 8000053c <panic>
    panic("sched interruptible");
    80002114:	00006517          	auipc	a0,0x6
    80002118:	13450513          	add	a0,a0,308 # 80008248 <digits+0x208>
    8000211c:	ffffe097          	auipc	ra,0xffffe
    80002120:	420080e7          	jalr	1056(ra) # 8000053c <panic>

0000000080002124 <yield>:
{
    80002124:	1101                	add	sp,sp,-32
    80002126:	ec06                	sd	ra,24(sp)
    80002128:	e822                	sd	s0,16(sp)
    8000212a:	e426                	sd	s1,8(sp)
    8000212c:	1000                	add	s0,sp,32
  struct proc *p = myproc();
    8000212e:	00000097          	auipc	ra,0x0
    80002132:	878080e7          	jalr	-1928(ra) # 800019a6 <myproc>
    80002136:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002138:	fffff097          	auipc	ra,0xfffff
    8000213c:	a9a080e7          	jalr	-1382(ra) # 80000bd2 <acquire>
  p->state = RUNNABLE;
    80002140:	478d                	li	a5,3
    80002142:	cc9c                	sw	a5,24(s1)
  sched();
    80002144:	00000097          	auipc	ra,0x0
    80002148:	f0a080e7          	jalr	-246(ra) # 8000204e <sched>
  release(&p->lock);
    8000214c:	8526                	mv	a0,s1
    8000214e:	fffff097          	auipc	ra,0xfffff
    80002152:	b38080e7          	jalr	-1224(ra) # 80000c86 <release>
}
    80002156:	60e2                	ld	ra,24(sp)
    80002158:	6442                	ld	s0,16(sp)
    8000215a:	64a2                	ld	s1,8(sp)
    8000215c:	6105                	add	sp,sp,32
    8000215e:	8082                	ret

0000000080002160 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002160:	7179                	add	sp,sp,-48
    80002162:	f406                	sd	ra,40(sp)
    80002164:	f022                	sd	s0,32(sp)
    80002166:	ec26                	sd	s1,24(sp)
    80002168:	e84a                	sd	s2,16(sp)
    8000216a:	e44e                	sd	s3,8(sp)
    8000216c:	1800                	add	s0,sp,48
    8000216e:	89aa                	mv	s3,a0
    80002170:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002172:	00000097          	auipc	ra,0x0
    80002176:	834080e7          	jalr	-1996(ra) # 800019a6 <myproc>
    8000217a:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000217c:	fffff097          	auipc	ra,0xfffff
    80002180:	a56080e7          	jalr	-1450(ra) # 80000bd2 <acquire>
  release(lk);
    80002184:	854a                	mv	a0,s2
    80002186:	fffff097          	auipc	ra,0xfffff
    8000218a:	b00080e7          	jalr	-1280(ra) # 80000c86 <release>

  // Go to sleep.
  p->chan = chan;
    8000218e:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002192:	4789                	li	a5,2
    80002194:	cc9c                	sw	a5,24(s1)
  	  #ifdef PBS	
    p->s_start_time = ticks;	
  #endif

  sched();
    80002196:	00000097          	auipc	ra,0x0
    8000219a:	eb8080e7          	jalr	-328(ra) # 8000204e <sched>

  // Tidy up.
  p->chan = 0;
    8000219e:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800021a2:	8526                	mv	a0,s1
    800021a4:	fffff097          	auipc	ra,0xfffff
    800021a8:	ae2080e7          	jalr	-1310(ra) # 80000c86 <release>
  acquire(lk);
    800021ac:	854a                	mv	a0,s2
    800021ae:	fffff097          	auipc	ra,0xfffff
    800021b2:	a24080e7          	jalr	-1500(ra) # 80000bd2 <acquire>
}
    800021b6:	70a2                	ld	ra,40(sp)
    800021b8:	7402                	ld	s0,32(sp)
    800021ba:	64e2                	ld	s1,24(sp)
    800021bc:	6942                	ld	s2,16(sp)
    800021be:	69a2                	ld	s3,8(sp)
    800021c0:	6145                	add	sp,sp,48
    800021c2:	8082                	ret

00000000800021c4 <waitx>:
{	
    800021c4:	711d                	add	sp,sp,-96
    800021c6:	ec86                	sd	ra,88(sp)
    800021c8:	e8a2                	sd	s0,80(sp)
    800021ca:	e4a6                	sd	s1,72(sp)
    800021cc:	e0ca                	sd	s2,64(sp)
    800021ce:	fc4e                	sd	s3,56(sp)
    800021d0:	f852                	sd	s4,48(sp)
    800021d2:	f456                	sd	s5,40(sp)
    800021d4:	f05a                	sd	s6,32(sp)
    800021d6:	ec5e                	sd	s7,24(sp)
    800021d8:	e862                	sd	s8,16(sp)
    800021da:	e466                	sd	s9,8(sp)
    800021dc:	e06a                	sd	s10,0(sp)
    800021de:	1080                	add	s0,sp,96
    800021e0:	8b2a                	mv	s6,a0
    800021e2:	8c2e                	mv	s8,a1
    800021e4:	8bb2                	mv	s7,a2
  struct proc *p = myproc();	
    800021e6:	fffff097          	auipc	ra,0xfffff
    800021ea:	7c0080e7          	jalr	1984(ra) # 800019a6 <myproc>
    800021ee:	892a                	mv	s2,a0
  acquire(&wait_lock);	
    800021f0:	0000f517          	auipc	a0,0xf
    800021f4:	bf850513          	add	a0,a0,-1032 # 80010de8 <wait_lock>
    800021f8:	fffff097          	auipc	ra,0xfffff
    800021fc:	9da080e7          	jalr	-1574(ra) # 80000bd2 <acquire>
    havekids = 0;	
    80002200:	4c81                	li	s9,0
        if(np->state == ZOMBIE){	
    80002202:	4a15                	li	s4,5
        havekids = 1;	
    80002204:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){	
    80002206:	00015997          	auipc	s3,0x15
    8000220a:	1fa98993          	add	s3,s3,506 # 80017400 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep	
    8000220e:	0000fd17          	auipc	s10,0xf
    80002212:	bdad0d13          	add	s10,s10,-1062 # 80010de8 <wait_lock>
    80002216:	a8e9                	j	800022f0 <waitx+0x12c>
          pid = np->pid;	
    80002218:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;	
    8000221c:	1784a783          	lw	a5,376(s1)
    80002220:	00fc2023          	sw	a5,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;	
    80002224:	17c4a703          	lw	a4,380(s1)
    80002228:	9f3d                	addw	a4,a4,a5
    8000222a:	1804a783          	lw	a5,384(s1)
    8000222e:	9f99                	subw	a5,a5,a4
    80002230:	00fba023          	sw	a5,0(s7) # fffffffffffff000 <end+0xffffffff7ffdc820>
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,	
    80002234:	000b0e63          	beqz	s6,80002250 <waitx+0x8c>
    80002238:	4691                	li	a3,4
    8000223a:	02c48613          	add	a2,s1,44
    8000223e:	85da                	mv	a1,s6
    80002240:	05093503          	ld	a0,80(s2)
    80002244:	fffff097          	auipc	ra,0xfffff
    80002248:	422080e7          	jalr	1058(ra) # 80001666 <copyout>
    8000224c:	04054363          	bltz	a0,80002292 <waitx+0xce>
          freeproc(np);	
    80002250:	8526                	mv	a0,s1
    80002252:	00000097          	auipc	ra,0x0
    80002256:	906080e7          	jalr	-1786(ra) # 80001b58 <freeproc>
          release(&np->lock);	
    8000225a:	8526                	mv	a0,s1
    8000225c:	fffff097          	auipc	ra,0xfffff
    80002260:	a2a080e7          	jalr	-1494(ra) # 80000c86 <release>
          release(&wait_lock);	
    80002264:	0000f517          	auipc	a0,0xf
    80002268:	b8450513          	add	a0,a0,-1148 # 80010de8 <wait_lock>
    8000226c:	fffff097          	auipc	ra,0xfffff
    80002270:	a1a080e7          	jalr	-1510(ra) # 80000c86 <release>
}	
    80002274:	854e                	mv	a0,s3
    80002276:	60e6                	ld	ra,88(sp)
    80002278:	6446                	ld	s0,80(sp)
    8000227a:	64a6                	ld	s1,72(sp)
    8000227c:	6906                	ld	s2,64(sp)
    8000227e:	79e2                	ld	s3,56(sp)
    80002280:	7a42                	ld	s4,48(sp)
    80002282:	7aa2                	ld	s5,40(sp)
    80002284:	7b02                	ld	s6,32(sp)
    80002286:	6be2                	ld	s7,24(sp)
    80002288:	6c42                	ld	s8,16(sp)
    8000228a:	6ca2                	ld	s9,8(sp)
    8000228c:	6d02                	ld	s10,0(sp)
    8000228e:	6125                	add	sp,sp,96
    80002290:	8082                	ret
            release(&np->lock);	
    80002292:	8526                	mv	a0,s1
    80002294:	fffff097          	auipc	ra,0xfffff
    80002298:	9f2080e7          	jalr	-1550(ra) # 80000c86 <release>
            release(&wait_lock);	
    8000229c:	0000f517          	auipc	a0,0xf
    800022a0:	b4c50513          	add	a0,a0,-1204 # 80010de8 <wait_lock>
    800022a4:	fffff097          	auipc	ra,0xfffff
    800022a8:	9e2080e7          	jalr	-1566(ra) # 80000c86 <release>
            return -1;	
    800022ac:	59fd                	li	s3,-1
    800022ae:	b7d9                	j	80002274 <waitx+0xb0>
    for(np = proc; np < &proc[NPROC]; np++){	
    800022b0:	18848493          	add	s1,s1,392
    800022b4:	03348463          	beq	s1,s3,800022dc <waitx+0x118>
      if(np->parent == p){	
    800022b8:	7c9c                	ld	a5,56(s1)
    800022ba:	ff279be3          	bne	a5,s2,800022b0 <waitx+0xec>
        acquire(&np->lock);	
    800022be:	8526                	mv	a0,s1
    800022c0:	fffff097          	auipc	ra,0xfffff
    800022c4:	912080e7          	jalr	-1774(ra) # 80000bd2 <acquire>
        if(np->state == ZOMBIE){	
    800022c8:	4c9c                	lw	a5,24(s1)
    800022ca:	f54787e3          	beq	a5,s4,80002218 <waitx+0x54>
        release(&np->lock);	
    800022ce:	8526                	mv	a0,s1
    800022d0:	fffff097          	auipc	ra,0xfffff
    800022d4:	9b6080e7          	jalr	-1610(ra) # 80000c86 <release>
        havekids = 1;	
    800022d8:	8756                	mv	a4,s5
    800022da:	bfd9                	j	800022b0 <waitx+0xec>
    if(!havekids || p->killed){	
    800022dc:	c305                	beqz	a4,800022fc <waitx+0x138>
    800022de:	02892783          	lw	a5,40(s2)
    800022e2:	ef89                	bnez	a5,800022fc <waitx+0x138>
    sleep(p, &wait_lock);  //DOC: wait-sleep	
    800022e4:	85ea                	mv	a1,s10
    800022e6:	854a                	mv	a0,s2
    800022e8:	00000097          	auipc	ra,0x0
    800022ec:	e78080e7          	jalr	-392(ra) # 80002160 <sleep>
    havekids = 0;	
    800022f0:	8766                	mv	a4,s9
    for(np = proc; np < &proc[NPROC]; np++){	
    800022f2:	0000f497          	auipc	s1,0xf
    800022f6:	f0e48493          	add	s1,s1,-242 # 80011200 <proc>
    800022fa:	bf7d                	j	800022b8 <waitx+0xf4>
      release(&wait_lock);	
    800022fc:	0000f517          	auipc	a0,0xf
    80002300:	aec50513          	add	a0,a0,-1300 # 80010de8 <wait_lock>
    80002304:	fffff097          	auipc	ra,0xfffff
    80002308:	982080e7          	jalr	-1662(ra) # 80000c86 <release>
      return -1;	
    8000230c:	59fd                	li	s3,-1
    8000230e:	b79d                	j	80002274 <waitx+0xb0>

0000000080002310 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002310:	7139                	add	sp,sp,-64
    80002312:	fc06                	sd	ra,56(sp)
    80002314:	f822                	sd	s0,48(sp)
    80002316:	f426                	sd	s1,40(sp)
    80002318:	f04a                	sd	s2,32(sp)
    8000231a:	ec4e                	sd	s3,24(sp)
    8000231c:	e852                	sd	s4,16(sp)
    8000231e:	e456                	sd	s5,8(sp)
    80002320:	0080                	add	s0,sp,64
    80002322:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002324:	0000f497          	auipc	s1,0xf
    80002328:	edc48493          	add	s1,s1,-292 # 80011200 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000232c:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000232e:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002330:	00015917          	auipc	s2,0x15
    80002334:	0d090913          	add	s2,s2,208 # 80017400 <tickslock>
    80002338:	a811                	j	8000234c <wakeup+0x3c>
         #ifdef PBS	
          p->stime = ticks - p->s_start_time;	
        #endif
      }
      release(&p->lock);
    8000233a:	8526                	mv	a0,s1
    8000233c:	fffff097          	auipc	ra,0xfffff
    80002340:	94a080e7          	jalr	-1718(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002344:	18848493          	add	s1,s1,392
    80002348:	03248663          	beq	s1,s2,80002374 <wakeup+0x64>
    if(p != myproc()){
    8000234c:	fffff097          	auipc	ra,0xfffff
    80002350:	65a080e7          	jalr	1626(ra) # 800019a6 <myproc>
    80002354:	fea488e3          	beq	s1,a0,80002344 <wakeup+0x34>
      acquire(&p->lock);
    80002358:	8526                	mv	a0,s1
    8000235a:	fffff097          	auipc	ra,0xfffff
    8000235e:	878080e7          	jalr	-1928(ra) # 80000bd2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002362:	4c9c                	lw	a5,24(s1)
    80002364:	fd379be3          	bne	a5,s3,8000233a <wakeup+0x2a>
    80002368:	709c                	ld	a5,32(s1)
    8000236a:	fd4798e3          	bne	a5,s4,8000233a <wakeup+0x2a>
        p->state = RUNNABLE;
    8000236e:	0154ac23          	sw	s5,24(s1)
    80002372:	b7e1                	j	8000233a <wakeup+0x2a>
    }
  }
}
    80002374:	70e2                	ld	ra,56(sp)
    80002376:	7442                	ld	s0,48(sp)
    80002378:	74a2                	ld	s1,40(sp)
    8000237a:	7902                	ld	s2,32(sp)
    8000237c:	69e2                	ld	s3,24(sp)
    8000237e:	6a42                	ld	s4,16(sp)
    80002380:	6aa2                	ld	s5,8(sp)
    80002382:	6121                	add	sp,sp,64
    80002384:	8082                	ret

0000000080002386 <reparent>:
{
    80002386:	7179                	add	sp,sp,-48
    80002388:	f406                	sd	ra,40(sp)
    8000238a:	f022                	sd	s0,32(sp)
    8000238c:	ec26                	sd	s1,24(sp)
    8000238e:	e84a                	sd	s2,16(sp)
    80002390:	e44e                	sd	s3,8(sp)
    80002392:	e052                	sd	s4,0(sp)
    80002394:	1800                	add	s0,sp,48
    80002396:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002398:	0000f497          	auipc	s1,0xf
    8000239c:	e6848493          	add	s1,s1,-408 # 80011200 <proc>
      pp->parent = initproc;
    800023a0:	00006a17          	auipc	s4,0x6
    800023a4:	7b8a0a13          	add	s4,s4,1976 # 80008b58 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800023a8:	00015997          	auipc	s3,0x15
    800023ac:	05898993          	add	s3,s3,88 # 80017400 <tickslock>
    800023b0:	a029                	j	800023ba <reparent+0x34>
    800023b2:	18848493          	add	s1,s1,392
    800023b6:	01348d63          	beq	s1,s3,800023d0 <reparent+0x4a>
    if(pp->parent == p){
    800023ba:	7c9c                	ld	a5,56(s1)
    800023bc:	ff279be3          	bne	a5,s2,800023b2 <reparent+0x2c>
      pp->parent = initproc;
    800023c0:	000a3503          	ld	a0,0(s4)
    800023c4:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800023c6:	00000097          	auipc	ra,0x0
    800023ca:	f4a080e7          	jalr	-182(ra) # 80002310 <wakeup>
    800023ce:	b7d5                	j	800023b2 <reparent+0x2c>
}
    800023d0:	70a2                	ld	ra,40(sp)
    800023d2:	7402                	ld	s0,32(sp)
    800023d4:	64e2                	ld	s1,24(sp)
    800023d6:	6942                	ld	s2,16(sp)
    800023d8:	69a2                	ld	s3,8(sp)
    800023da:	6a02                	ld	s4,0(sp)
    800023dc:	6145                	add	sp,sp,48
    800023de:	8082                	ret

00000000800023e0 <exit>:
{
    800023e0:	7179                	add	sp,sp,-48
    800023e2:	f406                	sd	ra,40(sp)
    800023e4:	f022                	sd	s0,32(sp)
    800023e6:	ec26                	sd	s1,24(sp)
    800023e8:	e84a                	sd	s2,16(sp)
    800023ea:	e44e                	sd	s3,8(sp)
    800023ec:	e052                	sd	s4,0(sp)
    800023ee:	1800                	add	s0,sp,48
    800023f0:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800023f2:	fffff097          	auipc	ra,0xfffff
    800023f6:	5b4080e7          	jalr	1460(ra) # 800019a6 <myproc>
    800023fa:	89aa                	mv	s3,a0
  if(p == initproc)
    800023fc:	00006797          	auipc	a5,0x6
    80002400:	75c7b783          	ld	a5,1884(a5) # 80008b58 <initproc>
    80002404:	0d050493          	add	s1,a0,208
    80002408:	15050913          	add	s2,a0,336
    8000240c:	02a79363          	bne	a5,a0,80002432 <exit+0x52>
    panic("init exiting");
    80002410:	00006517          	auipc	a0,0x6
    80002414:	e5050513          	add	a0,a0,-432 # 80008260 <digits+0x220>
    80002418:	ffffe097          	auipc	ra,0xffffe
    8000241c:	124080e7          	jalr	292(ra) # 8000053c <panic>
      fileclose(f);
    80002420:	00002097          	auipc	ra,0x2
    80002424:	4d6080e7          	jalr	1238(ra) # 800048f6 <fileclose>
      p->ofile[fd] = 0;
    80002428:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000242c:	04a1                	add	s1,s1,8
    8000242e:	01248563          	beq	s1,s2,80002438 <exit+0x58>
    if(p->ofile[fd]){
    80002432:	6088                	ld	a0,0(s1)
    80002434:	f575                	bnez	a0,80002420 <exit+0x40>
    80002436:	bfdd                	j	8000242c <exit+0x4c>
  begin_op();
    80002438:	00002097          	auipc	ra,0x2
    8000243c:	ffa080e7          	jalr	-6(ra) # 80004432 <begin_op>
  iput(p->cwd);
    80002440:	1509b503          	ld	a0,336(s3)
    80002444:	00002097          	auipc	ra,0x2
    80002448:	802080e7          	jalr	-2046(ra) # 80003c46 <iput>
  end_op();
    8000244c:	00002097          	auipc	ra,0x2
    80002450:	060080e7          	jalr	96(ra) # 800044ac <end_op>
  p->cwd = 0;
    80002454:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002458:	0000f497          	auipc	s1,0xf
    8000245c:	99048493          	add	s1,s1,-1648 # 80010de8 <wait_lock>
    80002460:	8526                	mv	a0,s1
    80002462:	ffffe097          	auipc	ra,0xffffe
    80002466:	770080e7          	jalr	1904(ra) # 80000bd2 <acquire>
  reparent(p);
    8000246a:	854e                	mv	a0,s3
    8000246c:	00000097          	auipc	ra,0x0
    80002470:	f1a080e7          	jalr	-230(ra) # 80002386 <reparent>
  wakeup(p->parent);
    80002474:	0389b503          	ld	a0,56(s3)
    80002478:	00000097          	auipc	ra,0x0
    8000247c:	e98080e7          	jalr	-360(ra) # 80002310 <wakeup>
  acquire(&p->lock);
    80002480:	854e                	mv	a0,s3
    80002482:	ffffe097          	auipc	ra,0xffffe
    80002486:	750080e7          	jalr	1872(ra) # 80000bd2 <acquire>
  p->xstate = status;
    8000248a:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000248e:	4795                	li	a5,5
    80002490:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    80002494:	00006797          	auipc	a5,0x6
    80002498:	6cc7a783          	lw	a5,1740(a5) # 80008b60 <ticks>
    8000249c:	18f9a023          	sw	a5,384(s3)
  release(&wait_lock);
    800024a0:	8526                	mv	a0,s1
    800024a2:	ffffe097          	auipc	ra,0xffffe
    800024a6:	7e4080e7          	jalr	2020(ra) # 80000c86 <release>
  sched();
    800024aa:	00000097          	auipc	ra,0x0
    800024ae:	ba4080e7          	jalr	-1116(ra) # 8000204e <sched>
  panic("zombie exit");
    800024b2:	00006517          	auipc	a0,0x6
    800024b6:	dbe50513          	add	a0,a0,-578 # 80008270 <digits+0x230>
    800024ba:	ffffe097          	auipc	ra,0xffffe
    800024be:	082080e7          	jalr	130(ra) # 8000053c <panic>

00000000800024c2 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800024c2:	7179                	add	sp,sp,-48
    800024c4:	f406                	sd	ra,40(sp)
    800024c6:	f022                	sd	s0,32(sp)
    800024c8:	ec26                	sd	s1,24(sp)
    800024ca:	e84a                	sd	s2,16(sp)
    800024cc:	e44e                	sd	s3,8(sp)
    800024ce:	1800                	add	s0,sp,48
    800024d0:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800024d2:	0000f497          	auipc	s1,0xf
    800024d6:	d2e48493          	add	s1,s1,-722 # 80011200 <proc>
    800024da:	00015997          	auipc	s3,0x15
    800024de:	f2698993          	add	s3,s3,-218 # 80017400 <tickslock>
    acquire(&p->lock);
    800024e2:	8526                	mv	a0,s1
    800024e4:	ffffe097          	auipc	ra,0xffffe
    800024e8:	6ee080e7          	jalr	1774(ra) # 80000bd2 <acquire>
    if(p->pid == pid){
    800024ec:	589c                	lw	a5,48(s1)
    800024ee:	01278d63          	beq	a5,s2,80002508 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800024f2:	8526                	mv	a0,s1
    800024f4:	ffffe097          	auipc	ra,0xffffe
    800024f8:	792080e7          	jalr	1938(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800024fc:	18848493          	add	s1,s1,392
    80002500:	ff3491e3          	bne	s1,s3,800024e2 <kill+0x20>
  }
  return -1;
    80002504:	557d                	li	a0,-1
    80002506:	a829                	j	80002520 <kill+0x5e>
      p->killed = 1;
    80002508:	4785                	li	a5,1
    8000250a:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000250c:	4c98                	lw	a4,24(s1)
    8000250e:	4789                	li	a5,2
    80002510:	00f70f63          	beq	a4,a5,8000252e <kill+0x6c>
      release(&p->lock);
    80002514:	8526                	mv	a0,s1
    80002516:	ffffe097          	auipc	ra,0xffffe
    8000251a:	770080e7          	jalr	1904(ra) # 80000c86 <release>
      return 0;
    8000251e:	4501                	li	a0,0
}
    80002520:	70a2                	ld	ra,40(sp)
    80002522:	7402                	ld	s0,32(sp)
    80002524:	64e2                	ld	s1,24(sp)
    80002526:	6942                	ld	s2,16(sp)
    80002528:	69a2                	ld	s3,8(sp)
    8000252a:	6145                	add	sp,sp,48
    8000252c:	8082                	ret
        p->state = RUNNABLE;
    8000252e:	478d                	li	a5,3
    80002530:	cc9c                	sw	a5,24(s1)
    80002532:	b7cd                	j	80002514 <kill+0x52>

0000000080002534 <setkilled>:

void
setkilled(struct proc *p)
{
    80002534:	1101                	add	sp,sp,-32
    80002536:	ec06                	sd	ra,24(sp)
    80002538:	e822                	sd	s0,16(sp)
    8000253a:	e426                	sd	s1,8(sp)
    8000253c:	1000                	add	s0,sp,32
    8000253e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002540:	ffffe097          	auipc	ra,0xffffe
    80002544:	692080e7          	jalr	1682(ra) # 80000bd2 <acquire>
  p->killed = 1;
    80002548:	4785                	li	a5,1
    8000254a:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000254c:	8526                	mv	a0,s1
    8000254e:	ffffe097          	auipc	ra,0xffffe
    80002552:	738080e7          	jalr	1848(ra) # 80000c86 <release>
}
    80002556:	60e2                	ld	ra,24(sp)
    80002558:	6442                	ld	s0,16(sp)
    8000255a:	64a2                	ld	s1,8(sp)
    8000255c:	6105                	add	sp,sp,32
    8000255e:	8082                	ret

0000000080002560 <killed>:

int
killed(struct proc *p)
{
    80002560:	1101                	add	sp,sp,-32
    80002562:	ec06                	sd	ra,24(sp)
    80002564:	e822                	sd	s0,16(sp)
    80002566:	e426                	sd	s1,8(sp)
    80002568:	e04a                	sd	s2,0(sp)
    8000256a:	1000                	add	s0,sp,32
    8000256c:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000256e:	ffffe097          	auipc	ra,0xffffe
    80002572:	664080e7          	jalr	1636(ra) # 80000bd2 <acquire>
  k = p->killed;
    80002576:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000257a:	8526                	mv	a0,s1
    8000257c:	ffffe097          	auipc	ra,0xffffe
    80002580:	70a080e7          	jalr	1802(ra) # 80000c86 <release>
  return k;
}
    80002584:	854a                	mv	a0,s2
    80002586:	60e2                	ld	ra,24(sp)
    80002588:	6442                	ld	s0,16(sp)
    8000258a:	64a2                	ld	s1,8(sp)
    8000258c:	6902                	ld	s2,0(sp)
    8000258e:	6105                	add	sp,sp,32
    80002590:	8082                	ret

0000000080002592 <wait>:
{
    80002592:	715d                	add	sp,sp,-80
    80002594:	e486                	sd	ra,72(sp)
    80002596:	e0a2                	sd	s0,64(sp)
    80002598:	fc26                	sd	s1,56(sp)
    8000259a:	f84a                	sd	s2,48(sp)
    8000259c:	f44e                	sd	s3,40(sp)
    8000259e:	f052                	sd	s4,32(sp)
    800025a0:	ec56                	sd	s5,24(sp)
    800025a2:	e85a                	sd	s6,16(sp)
    800025a4:	e45e                	sd	s7,8(sp)
    800025a6:	e062                	sd	s8,0(sp)
    800025a8:	0880                	add	s0,sp,80
    800025aa:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800025ac:	fffff097          	auipc	ra,0xfffff
    800025b0:	3fa080e7          	jalr	1018(ra) # 800019a6 <myproc>
    800025b4:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800025b6:	0000f517          	auipc	a0,0xf
    800025ba:	83250513          	add	a0,a0,-1998 # 80010de8 <wait_lock>
    800025be:	ffffe097          	auipc	ra,0xffffe
    800025c2:	614080e7          	jalr	1556(ra) # 80000bd2 <acquire>
    havekids = 0;
    800025c6:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800025c8:	4a15                	li	s4,5
        havekids = 1;
    800025ca:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800025cc:	00015997          	auipc	s3,0x15
    800025d0:	e3498993          	add	s3,s3,-460 # 80017400 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800025d4:	0000fc17          	auipc	s8,0xf
    800025d8:	814c0c13          	add	s8,s8,-2028 # 80010de8 <wait_lock>
    800025dc:	a0d1                	j	800026a0 <wait+0x10e>
          pid = pp->pid;
    800025de:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800025e2:	000b0e63          	beqz	s6,800025fe <wait+0x6c>
    800025e6:	4691                	li	a3,4
    800025e8:	02c48613          	add	a2,s1,44
    800025ec:	85da                	mv	a1,s6
    800025ee:	05093503          	ld	a0,80(s2)
    800025f2:	fffff097          	auipc	ra,0xfffff
    800025f6:	074080e7          	jalr	116(ra) # 80001666 <copyout>
    800025fa:	04054163          	bltz	a0,8000263c <wait+0xaa>
          freeproc(pp);
    800025fe:	8526                	mv	a0,s1
    80002600:	fffff097          	auipc	ra,0xfffff
    80002604:	558080e7          	jalr	1368(ra) # 80001b58 <freeproc>
          release(&pp->lock);
    80002608:	8526                	mv	a0,s1
    8000260a:	ffffe097          	auipc	ra,0xffffe
    8000260e:	67c080e7          	jalr	1660(ra) # 80000c86 <release>
          release(&wait_lock);
    80002612:	0000e517          	auipc	a0,0xe
    80002616:	7d650513          	add	a0,a0,2006 # 80010de8 <wait_lock>
    8000261a:	ffffe097          	auipc	ra,0xffffe
    8000261e:	66c080e7          	jalr	1644(ra) # 80000c86 <release>
}
    80002622:	854e                	mv	a0,s3
    80002624:	60a6                	ld	ra,72(sp)
    80002626:	6406                	ld	s0,64(sp)
    80002628:	74e2                	ld	s1,56(sp)
    8000262a:	7942                	ld	s2,48(sp)
    8000262c:	79a2                	ld	s3,40(sp)
    8000262e:	7a02                	ld	s4,32(sp)
    80002630:	6ae2                	ld	s5,24(sp)
    80002632:	6b42                	ld	s6,16(sp)
    80002634:	6ba2                	ld	s7,8(sp)
    80002636:	6c02                	ld	s8,0(sp)
    80002638:	6161                	add	sp,sp,80
    8000263a:	8082                	ret
            release(&pp->lock);
    8000263c:	8526                	mv	a0,s1
    8000263e:	ffffe097          	auipc	ra,0xffffe
    80002642:	648080e7          	jalr	1608(ra) # 80000c86 <release>
            release(&wait_lock);
    80002646:	0000e517          	auipc	a0,0xe
    8000264a:	7a250513          	add	a0,a0,1954 # 80010de8 <wait_lock>
    8000264e:	ffffe097          	auipc	ra,0xffffe
    80002652:	638080e7          	jalr	1592(ra) # 80000c86 <release>
            return -1;
    80002656:	59fd                	li	s3,-1
    80002658:	b7e9                	j	80002622 <wait+0x90>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000265a:	18848493          	add	s1,s1,392
    8000265e:	03348463          	beq	s1,s3,80002686 <wait+0xf4>
      if(pp->parent == p){
    80002662:	7c9c                	ld	a5,56(s1)
    80002664:	ff279be3          	bne	a5,s2,8000265a <wait+0xc8>
        acquire(&pp->lock);
    80002668:	8526                	mv	a0,s1
    8000266a:	ffffe097          	auipc	ra,0xffffe
    8000266e:	568080e7          	jalr	1384(ra) # 80000bd2 <acquire>
        if(pp->state == ZOMBIE){
    80002672:	4c9c                	lw	a5,24(s1)
    80002674:	f74785e3          	beq	a5,s4,800025de <wait+0x4c>
        release(&pp->lock);
    80002678:	8526                	mv	a0,s1
    8000267a:	ffffe097          	auipc	ra,0xffffe
    8000267e:	60c080e7          	jalr	1548(ra) # 80000c86 <release>
        havekids = 1;
    80002682:	8756                	mv	a4,s5
    80002684:	bfd9                	j	8000265a <wait+0xc8>
    if(!havekids || killed(p)){
    80002686:	c31d                	beqz	a4,800026ac <wait+0x11a>
    80002688:	854a                	mv	a0,s2
    8000268a:	00000097          	auipc	ra,0x0
    8000268e:	ed6080e7          	jalr	-298(ra) # 80002560 <killed>
    80002692:	ed09                	bnez	a0,800026ac <wait+0x11a>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002694:	85e2                	mv	a1,s8
    80002696:	854a                	mv	a0,s2
    80002698:	00000097          	auipc	ra,0x0
    8000269c:	ac8080e7          	jalr	-1336(ra) # 80002160 <sleep>
    havekids = 0;
    800026a0:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800026a2:	0000f497          	auipc	s1,0xf
    800026a6:	b5e48493          	add	s1,s1,-1186 # 80011200 <proc>
    800026aa:	bf65                	j	80002662 <wait+0xd0>
      release(&wait_lock);
    800026ac:	0000e517          	auipc	a0,0xe
    800026b0:	73c50513          	add	a0,a0,1852 # 80010de8 <wait_lock>
    800026b4:	ffffe097          	auipc	ra,0xffffe
    800026b8:	5d2080e7          	jalr	1490(ra) # 80000c86 <release>
      return -1;
    800026bc:	59fd                	li	s3,-1
    800026be:	b795                	j	80002622 <wait+0x90>

00000000800026c0 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800026c0:	7179                	add	sp,sp,-48
    800026c2:	f406                	sd	ra,40(sp)
    800026c4:	f022                	sd	s0,32(sp)
    800026c6:	ec26                	sd	s1,24(sp)
    800026c8:	e84a                	sd	s2,16(sp)
    800026ca:	e44e                	sd	s3,8(sp)
    800026cc:	e052                	sd	s4,0(sp)
    800026ce:	1800                	add	s0,sp,48
    800026d0:	84aa                	mv	s1,a0
    800026d2:	892e                	mv	s2,a1
    800026d4:	89b2                	mv	s3,a2
    800026d6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800026d8:	fffff097          	auipc	ra,0xfffff
    800026dc:	2ce080e7          	jalr	718(ra) # 800019a6 <myproc>
  if(user_dst){
    800026e0:	c08d                	beqz	s1,80002702 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800026e2:	86d2                	mv	a3,s4
    800026e4:	864e                	mv	a2,s3
    800026e6:	85ca                	mv	a1,s2
    800026e8:	6928                	ld	a0,80(a0)
    800026ea:	fffff097          	auipc	ra,0xfffff
    800026ee:	f7c080e7          	jalr	-132(ra) # 80001666 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800026f2:	70a2                	ld	ra,40(sp)
    800026f4:	7402                	ld	s0,32(sp)
    800026f6:	64e2                	ld	s1,24(sp)
    800026f8:	6942                	ld	s2,16(sp)
    800026fa:	69a2                	ld	s3,8(sp)
    800026fc:	6a02                	ld	s4,0(sp)
    800026fe:	6145                	add	sp,sp,48
    80002700:	8082                	ret
    memmove((char *)dst, src, len);
    80002702:	000a061b          	sext.w	a2,s4
    80002706:	85ce                	mv	a1,s3
    80002708:	854a                	mv	a0,s2
    8000270a:	ffffe097          	auipc	ra,0xffffe
    8000270e:	620080e7          	jalr	1568(ra) # 80000d2a <memmove>
    return 0;
    80002712:	8526                	mv	a0,s1
    80002714:	bff9                	j	800026f2 <either_copyout+0x32>

0000000080002716 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002716:	7179                	add	sp,sp,-48
    80002718:	f406                	sd	ra,40(sp)
    8000271a:	f022                	sd	s0,32(sp)
    8000271c:	ec26                	sd	s1,24(sp)
    8000271e:	e84a                	sd	s2,16(sp)
    80002720:	e44e                	sd	s3,8(sp)
    80002722:	e052                	sd	s4,0(sp)
    80002724:	1800                	add	s0,sp,48
    80002726:	892a                	mv	s2,a0
    80002728:	84ae                	mv	s1,a1
    8000272a:	89b2                	mv	s3,a2
    8000272c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000272e:	fffff097          	auipc	ra,0xfffff
    80002732:	278080e7          	jalr	632(ra) # 800019a6 <myproc>
  if(user_src){
    80002736:	c08d                	beqz	s1,80002758 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002738:	86d2                	mv	a3,s4
    8000273a:	864e                	mv	a2,s3
    8000273c:	85ca                	mv	a1,s2
    8000273e:	6928                	ld	a0,80(a0)
    80002740:	fffff097          	auipc	ra,0xfffff
    80002744:	fb2080e7          	jalr	-78(ra) # 800016f2 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002748:	70a2                	ld	ra,40(sp)
    8000274a:	7402                	ld	s0,32(sp)
    8000274c:	64e2                	ld	s1,24(sp)
    8000274e:	6942                	ld	s2,16(sp)
    80002750:	69a2                	ld	s3,8(sp)
    80002752:	6a02                	ld	s4,0(sp)
    80002754:	6145                	add	sp,sp,48
    80002756:	8082                	ret
    memmove(dst, (char*)src, len);
    80002758:	000a061b          	sext.w	a2,s4
    8000275c:	85ce                	mv	a1,s3
    8000275e:	854a                	mv	a0,s2
    80002760:	ffffe097          	auipc	ra,0xffffe
    80002764:	5ca080e7          	jalr	1482(ra) # 80000d2a <memmove>
    return 0;
    80002768:	8526                	mv	a0,s1
    8000276a:	bff9                	j	80002748 <either_copyin+0x32>

000000008000276c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000276c:	715d                	add	sp,sp,-80
    8000276e:	e486                	sd	ra,72(sp)
    80002770:	e0a2                	sd	s0,64(sp)
    80002772:	fc26                	sd	s1,56(sp)
    80002774:	f84a                	sd	s2,48(sp)
    80002776:	f44e                	sd	s3,40(sp)
    80002778:	f052                	sd	s4,32(sp)
    8000277a:	ec56                	sd	s5,24(sp)
    8000277c:	e85a                	sd	s6,16(sp)
    8000277e:	e45e                	sd	s7,8(sp)
    80002780:	e062                	sd	s8,0(sp)
    80002782:	0880                	add	s0,sp,80
  char *state;
   #ifdef RR	
    printf("\nPID\tState\trtime\twtime\tnrun");	
  #endif	
   #ifdef FCFS	
    printf("\nPID\tState\trtime\twtime\tnrun");	
    80002784:	00006517          	auipc	a0,0x6
    80002788:	b0450513          	add	a0,a0,-1276 # 80008288 <digits+0x248>
    8000278c:	ffffe097          	auipc	ra,0xffffe
    80002790:	dfa080e7          	jalr	-518(ra) # 80000586 <printf>
  #endif	
  #ifdef MLFQ	
    printf("\nPID\tPrio\tState\trtime\twtime\tnrun\tq0\tq1\tq2\tq3\tq4");	
  #endif

  printf("\n");
    80002794:	00006517          	auipc	a0,0x6
    80002798:	93450513          	add	a0,a0,-1740 # 800080c8 <digits+0x88>
    8000279c:	ffffe097          	auipc	ra,0xffffe
    800027a0:	dea080e7          	jalr	-534(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800027a4:	0000f497          	auipc	s1,0xf
    800027a8:	a5c48493          	add	s1,s1,-1444 # 80011200 <proc>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027ac:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800027ae:	00006997          	auipc	s3,0x6
    800027b2:	ad298993          	add	s3,s3,-1326 # 80008280 <digits+0x240>
      #endif
      #ifdef FCFS
      int end_time = p->etime;	
      if (end_time == 0)	
        end_time = ticks;	
      printf("%d\t%s\t%d\t%d\t%d", p->pid, state, p->rtime, end_time - p->ctime - p->rtime, p->no_of_times_scheduled);	
    800027b6:	00006a97          	auipc	s5,0x6
    800027ba:	af2a8a93          	add	s5,s5,-1294 # 800082a8 <digits+0x268>
      printf("\n");	
    800027be:	00006a17          	auipc	s4,0x6
    800027c2:	90aa0a13          	add	s4,s4,-1782 # 800080c8 <digits+0x88>
        end_time = ticks;	
    800027c6:	00006c17          	auipc	s8,0x6
    800027ca:	39ac0c13          	add	s8,s8,922 # 80008b60 <ticks>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027ce:	00006b97          	auipc	s7,0x6
    800027d2:	b1ab8b93          	add	s7,s7,-1254 # 800082e8 <states.0>
  for(p = proc; p < &proc[NPROC]; p++){
    800027d6:	00015917          	auipc	s2,0x15
    800027da:	c2a90913          	add	s2,s2,-982 # 80017400 <tickslock>
    800027de:	a835                	j	8000281a <procdump+0xae>
      int end_time = p->etime;	
    800027e0:	1804a583          	lw	a1,384(s1)
      if (end_time == 0)	
    800027e4:	e199                	bnez	a1,800027ea <procdump+0x7e>
        end_time = ticks;	
    800027e6:	000c2583          	lw	a1,0(s8)
      printf("%d\t%s\t%d\t%d\t%d", p->pid, state, p->rtime, end_time - p->ctime - p->rtime, p->no_of_times_scheduled);	
    800027ea:	1784a683          	lw	a3,376(s1)
    800027ee:	17c4a703          	lw	a4,380(s1)
    800027f2:	9f35                	addw	a4,a4,a3
    800027f4:	1844a783          	lw	a5,388(s1)
    800027f8:	40e5873b          	subw	a4,a1,a4
    800027fc:	588c                	lw	a1,48(s1)
    800027fe:	8556                	mv	a0,s5
    80002800:	ffffe097          	auipc	ra,0xffffe
    80002804:	d86080e7          	jalr	-634(ra) # 80000586 <printf>
      printf("\n");	
    80002808:	8552                	mv	a0,s4
    8000280a:	ffffe097          	auipc	ra,0xffffe
    8000280e:	d7c080e7          	jalr	-644(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002812:	18848493          	add	s1,s1,392
    80002816:	03248063          	beq	s1,s2,80002836 <procdump+0xca>
    if(p->state == UNUSED)
    8000281a:	4c9c                	lw	a5,24(s1)
    8000281c:	dbfd                	beqz	a5,80002812 <procdump+0xa6>
      state = "???";
    8000281e:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002820:	fcfb60e3          	bltu	s6,a5,800027e0 <procdump+0x74>
    80002824:	02079713          	sll	a4,a5,0x20
    80002828:	01d75793          	srl	a5,a4,0x1d
    8000282c:	97de                	add	a5,a5,s7
    8000282e:	6390                	ld	a2,0(a5)
    80002830:	fa45                	bnez	a2,800027e0 <procdump+0x74>
      state = "???";
    80002832:	864e                	mv	a2,s3
    80002834:	b775                	j	800027e0 <procdump+0x74>
        current_queue = -1;	
      printf("%d\t%d\t%s\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d", p->pid, current_queue, state, p->rtime, end_time - p->ctime - p->rtime, p->no_of_times_scheduled, p->queue_ticks[0], p->queue_ticks[1], p->queue_ticks[2], p->queue_ticks[3], p->queue_ticks[4]);	
      printf("\n");	
    #endif
  }
}
    80002836:	60a6                	ld	ra,72(sp)
    80002838:	6406                	ld	s0,64(sp)
    8000283a:	74e2                	ld	s1,56(sp)
    8000283c:	7942                	ld	s2,48(sp)
    8000283e:	79a2                	ld	s3,40(sp)
    80002840:	7a02                	ld	s4,32(sp)
    80002842:	6ae2                	ld	s5,24(sp)
    80002844:	6b42                	ld	s6,16(sp)
    80002846:	6ba2                	ld	s7,8(sp)
    80002848:	6c02                	ld	s8,0(sp)
    8000284a:	6161                	add	sp,sp,80
    8000284c:	8082                	ret

000000008000284e <swtch>:
    8000284e:	00153023          	sd	ra,0(a0)
    80002852:	00253423          	sd	sp,8(a0)
    80002856:	e900                	sd	s0,16(a0)
    80002858:	ed04                	sd	s1,24(a0)
    8000285a:	03253023          	sd	s2,32(a0)
    8000285e:	03353423          	sd	s3,40(a0)
    80002862:	03453823          	sd	s4,48(a0)
    80002866:	03553c23          	sd	s5,56(a0)
    8000286a:	05653023          	sd	s6,64(a0)
    8000286e:	05753423          	sd	s7,72(a0)
    80002872:	05853823          	sd	s8,80(a0)
    80002876:	05953c23          	sd	s9,88(a0)
    8000287a:	07a53023          	sd	s10,96(a0)
    8000287e:	07b53423          	sd	s11,104(a0)
    80002882:	0005b083          	ld	ra,0(a1)
    80002886:	0085b103          	ld	sp,8(a1)
    8000288a:	6980                	ld	s0,16(a1)
    8000288c:	6d84                	ld	s1,24(a1)
    8000288e:	0205b903          	ld	s2,32(a1)
    80002892:	0285b983          	ld	s3,40(a1)
    80002896:	0305ba03          	ld	s4,48(a1)
    8000289a:	0385ba83          	ld	s5,56(a1)
    8000289e:	0405bb03          	ld	s6,64(a1)
    800028a2:	0485bb83          	ld	s7,72(a1)
    800028a6:	0505bc03          	ld	s8,80(a1)
    800028aa:	0585bc83          	ld	s9,88(a1)
    800028ae:	0605bd03          	ld	s10,96(a1)
    800028b2:	0685bd83          	ld	s11,104(a1)
    800028b6:	8082                	ret

00000000800028b8 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800028b8:	1141                	add	sp,sp,-16
    800028ba:	e406                	sd	ra,8(sp)
    800028bc:	e022                	sd	s0,0(sp)
    800028be:	0800                	add	s0,sp,16
  initlock(&tickslock, "time");
    800028c0:	00006597          	auipc	a1,0x6
    800028c4:	a5858593          	add	a1,a1,-1448 # 80008318 <states.0+0x30>
    800028c8:	00015517          	auipc	a0,0x15
    800028cc:	b3850513          	add	a0,a0,-1224 # 80017400 <tickslock>
    800028d0:	ffffe097          	auipc	ra,0xffffe
    800028d4:	272080e7          	jalr	626(ra) # 80000b42 <initlock>
}
    800028d8:	60a2                	ld	ra,8(sp)
    800028da:	6402                	ld	s0,0(sp)
    800028dc:	0141                	add	sp,sp,16
    800028de:	8082                	ret

00000000800028e0 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800028e0:	1141                	add	sp,sp,-16
    800028e2:	e422                	sd	s0,8(sp)
    800028e4:	0800                	add	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028e6:	00003797          	auipc	a5,0x3
    800028ea:	63a78793          	add	a5,a5,1594 # 80005f20 <kernelvec>
    800028ee:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800028f2:	6422                	ld	s0,8(sp)
    800028f4:	0141                	add	sp,sp,16
    800028f6:	8082                	ret

00000000800028f8 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800028f8:	1141                	add	sp,sp,-16
    800028fa:	e406                	sd	ra,8(sp)
    800028fc:	e022                	sd	s0,0(sp)
    800028fe:	0800                	add	s0,sp,16
  struct proc *p = myproc();
    80002900:	fffff097          	auipc	ra,0xfffff
    80002904:	0a6080e7          	jalr	166(ra) # 800019a6 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002908:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000290c:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000290e:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002912:	00004697          	auipc	a3,0x4
    80002916:	6ee68693          	add	a3,a3,1774 # 80007000 <_trampoline>
    8000291a:	00004717          	auipc	a4,0x4
    8000291e:	6e670713          	add	a4,a4,1766 # 80007000 <_trampoline>
    80002922:	8f15                	sub	a4,a4,a3
    80002924:	040007b7          	lui	a5,0x4000
    80002928:	17fd                	add	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    8000292a:	07b2                	sll	a5,a5,0xc
    8000292c:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000292e:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002932:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002934:	18002673          	csrr	a2,satp
    80002938:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000293a:	6d30                	ld	a2,88(a0)
    8000293c:	6138                	ld	a4,64(a0)
    8000293e:	6585                	lui	a1,0x1
    80002940:	972e                	add	a4,a4,a1
    80002942:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002944:	6d38                	ld	a4,88(a0)
    80002946:	00000617          	auipc	a2,0x0
    8000294a:	14260613          	add	a2,a2,322 # 80002a88 <usertrap>
    8000294e:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002950:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002952:	8612                	mv	a2,tp
    80002954:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002956:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000295a:	eff77713          	and	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000295e:	02076713          	or	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002962:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002966:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002968:	6f18                	ld	a4,24(a4)
    8000296a:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000296e:	6928                	ld	a0,80(a0)
    80002970:	8131                	srl	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002972:	00004717          	auipc	a4,0x4
    80002976:	72a70713          	add	a4,a4,1834 # 8000709c <userret>
    8000297a:	8f15                	sub	a4,a4,a3
    8000297c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    8000297e:	577d                	li	a4,-1
    80002980:	177e                	sll	a4,a4,0x3f
    80002982:	8d59                	or	a0,a0,a4
    80002984:	9782                	jalr	a5
}
    80002986:	60a2                	ld	ra,8(sp)
    80002988:	6402                	ld	s0,0(sp)
    8000298a:	0141                	add	sp,sp,16
    8000298c:	8082                	ret

000000008000298e <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000298e:	1101                	add	sp,sp,-32
    80002990:	ec06                	sd	ra,24(sp)
    80002992:	e822                	sd	s0,16(sp)
    80002994:	e426                	sd	s1,8(sp)
    80002996:	e04a                	sd	s2,0(sp)
    80002998:	1000                	add	s0,sp,32
  acquire(&tickslock);
    8000299a:	00015917          	auipc	s2,0x15
    8000299e:	a6690913          	add	s2,s2,-1434 # 80017400 <tickslock>
    800029a2:	854a                	mv	a0,s2
    800029a4:	ffffe097          	auipc	ra,0xffffe
    800029a8:	22e080e7          	jalr	558(ra) # 80000bd2 <acquire>
  ticks++;
    800029ac:	00006497          	auipc	s1,0x6
    800029b0:	1b448493          	add	s1,s1,436 # 80008b60 <ticks>
    800029b4:	409c                	lw	a5,0(s1)
    800029b6:	2785                	addw	a5,a5,1
    800029b8:	c09c                	sw	a5,0(s1)
   update_time();
    800029ba:	fffff097          	auipc	ra,0xfffff
    800029be:	506080e7          	jalr	1286(ra) # 80001ec0 <update_time>
  wakeup(&ticks);
    800029c2:	8526                	mv	a0,s1
    800029c4:	00000097          	auipc	ra,0x0
    800029c8:	94c080e7          	jalr	-1716(ra) # 80002310 <wakeup>
  release(&tickslock);
    800029cc:	854a                	mv	a0,s2
    800029ce:	ffffe097          	auipc	ra,0xffffe
    800029d2:	2b8080e7          	jalr	696(ra) # 80000c86 <release>
}
    800029d6:	60e2                	ld	ra,24(sp)
    800029d8:	6442                	ld	s0,16(sp)
    800029da:	64a2                	ld	s1,8(sp)
    800029dc:	6902                	ld	s2,0(sp)
    800029de:	6105                	add	sp,sp,32
    800029e0:	8082                	ret

00000000800029e2 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029e2:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800029e6:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    800029e8:	0807df63          	bgez	a5,80002a86 <devintr+0xa4>
{
    800029ec:	1101                	add	sp,sp,-32
    800029ee:	ec06                	sd	ra,24(sp)
    800029f0:	e822                	sd	s0,16(sp)
    800029f2:	e426                	sd	s1,8(sp)
    800029f4:	1000                	add	s0,sp,32
     (scause & 0xff) == 9){
    800029f6:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    800029fa:	46a5                	li	a3,9
    800029fc:	00d70d63          	beq	a4,a3,80002a16 <devintr+0x34>
  } else if(scause == 0x8000000000000001L){
    80002a00:	577d                	li	a4,-1
    80002a02:	177e                	sll	a4,a4,0x3f
    80002a04:	0705                	add	a4,a4,1
    return 0;
    80002a06:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002a08:	04e78e63          	beq	a5,a4,80002a64 <devintr+0x82>
  }
}
    80002a0c:	60e2                	ld	ra,24(sp)
    80002a0e:	6442                	ld	s0,16(sp)
    80002a10:	64a2                	ld	s1,8(sp)
    80002a12:	6105                	add	sp,sp,32
    80002a14:	8082                	ret
    int irq = plic_claim();
    80002a16:	00003097          	auipc	ra,0x3
    80002a1a:	612080e7          	jalr	1554(ra) # 80006028 <plic_claim>
    80002a1e:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002a20:	47a9                	li	a5,10
    80002a22:	02f50763          	beq	a0,a5,80002a50 <devintr+0x6e>
    } else if(irq == VIRTIO0_IRQ){
    80002a26:	4785                	li	a5,1
    80002a28:	02f50963          	beq	a0,a5,80002a5a <devintr+0x78>
    return 1;
    80002a2c:	4505                	li	a0,1
    } else if(irq){
    80002a2e:	dcf9                	beqz	s1,80002a0c <devintr+0x2a>
      printf("unexpected interrupt irq=%d\n", irq);
    80002a30:	85a6                	mv	a1,s1
    80002a32:	00006517          	auipc	a0,0x6
    80002a36:	8ee50513          	add	a0,a0,-1810 # 80008320 <states.0+0x38>
    80002a3a:	ffffe097          	auipc	ra,0xffffe
    80002a3e:	b4c080e7          	jalr	-1204(ra) # 80000586 <printf>
      plic_complete(irq);
    80002a42:	8526                	mv	a0,s1
    80002a44:	00003097          	auipc	ra,0x3
    80002a48:	608080e7          	jalr	1544(ra) # 8000604c <plic_complete>
    return 1;
    80002a4c:	4505                	li	a0,1
    80002a4e:	bf7d                	j	80002a0c <devintr+0x2a>
      uartintr();
    80002a50:	ffffe097          	auipc	ra,0xffffe
    80002a54:	f44080e7          	jalr	-188(ra) # 80000994 <uartintr>
    if(irq)
    80002a58:	b7ed                	j	80002a42 <devintr+0x60>
      virtio_disk_intr();
    80002a5a:	00004097          	auipc	ra,0x4
    80002a5e:	ab8080e7          	jalr	-1352(ra) # 80006512 <virtio_disk_intr>
    if(irq)
    80002a62:	b7c5                	j	80002a42 <devintr+0x60>
    if(cpuid() == 0){
    80002a64:	fffff097          	auipc	ra,0xfffff
    80002a68:	f16080e7          	jalr	-234(ra) # 8000197a <cpuid>
    80002a6c:	c901                	beqz	a0,80002a7c <devintr+0x9a>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002a6e:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002a72:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002a74:	14479073          	csrw	sip,a5
    return 2;
    80002a78:	4509                	li	a0,2
    80002a7a:	bf49                	j	80002a0c <devintr+0x2a>
      clockintr();
    80002a7c:	00000097          	auipc	ra,0x0
    80002a80:	f12080e7          	jalr	-238(ra) # 8000298e <clockintr>
    80002a84:	b7ed                	j	80002a6e <devintr+0x8c>
}
    80002a86:	8082                	ret

0000000080002a88 <usertrap>:
{
    80002a88:	1101                	add	sp,sp,-32
    80002a8a:	ec06                	sd	ra,24(sp)
    80002a8c:	e822                	sd	s0,16(sp)
    80002a8e:	e426                	sd	s1,8(sp)
    80002a90:	1000                	add	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a92:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002a96:	1007f793          	and	a5,a5,256
    80002a9a:	eba9                	bnez	a5,80002aec <usertrap+0x64>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a9c:	00003797          	auipc	a5,0x3
    80002aa0:	48478793          	add	a5,a5,1156 # 80005f20 <kernelvec>
    80002aa4:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002aa8:	fffff097          	auipc	ra,0xfffff
    80002aac:	efe080e7          	jalr	-258(ra) # 800019a6 <myproc>
    80002ab0:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002ab2:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ab4:	14102773          	csrr	a4,sepc
    80002ab8:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002aba:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002abe:	47a1                	li	a5,8
    80002ac0:	02f70e63          	beq	a4,a5,80002afc <usertrap+0x74>
  } else if((which_dev = devintr()) != 0){
    80002ac4:	00000097          	auipc	ra,0x0
    80002ac8:	f1e080e7          	jalr	-226(ra) # 800029e2 <devintr>
    80002acc:	c135                	beqz	a0,80002b30 <usertrap+0xa8>
  if(killed(p))
    80002ace:	8526                	mv	a0,s1
    80002ad0:	00000097          	auipc	ra,0x0
    80002ad4:	a90080e7          	jalr	-1392(ra) # 80002560 <killed>
    80002ad8:	e949                	bnez	a0,80002b6a <usertrap+0xe2>
  usertrapret();
    80002ada:	00000097          	auipc	ra,0x0
    80002ade:	e1e080e7          	jalr	-482(ra) # 800028f8 <usertrapret>
}
    80002ae2:	60e2                	ld	ra,24(sp)
    80002ae4:	6442                	ld	s0,16(sp)
    80002ae6:	64a2                	ld	s1,8(sp)
    80002ae8:	6105                	add	sp,sp,32
    80002aea:	8082                	ret
    panic("usertrap: not from user mode");
    80002aec:	00006517          	auipc	a0,0x6
    80002af0:	85450513          	add	a0,a0,-1964 # 80008340 <states.0+0x58>
    80002af4:	ffffe097          	auipc	ra,0xffffe
    80002af8:	a48080e7          	jalr	-1464(ra) # 8000053c <panic>
    if(killed(p))
    80002afc:	00000097          	auipc	ra,0x0
    80002b00:	a64080e7          	jalr	-1436(ra) # 80002560 <killed>
    80002b04:	e105                	bnez	a0,80002b24 <usertrap+0x9c>
    p->trapframe->epc += 4;
    80002b06:	6cb8                	ld	a4,88(s1)
    80002b08:	6f1c                	ld	a5,24(a4)
    80002b0a:	0791                	add	a5,a5,4
    80002b0c:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b0e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002b12:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b16:	10079073          	csrw	sstatus,a5
    syscall();
    80002b1a:	00000097          	auipc	ra,0x0
    80002b1e:	274080e7          	jalr	628(ra) # 80002d8e <syscall>
    80002b22:	b775                	j	80002ace <usertrap+0x46>
      exit(-1);
    80002b24:	557d                	li	a0,-1
    80002b26:	00000097          	auipc	ra,0x0
    80002b2a:	8ba080e7          	jalr	-1862(ra) # 800023e0 <exit>
    80002b2e:	bfe1                	j	80002b06 <usertrap+0x7e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b30:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002b34:	5890                	lw	a2,48(s1)
    80002b36:	00006517          	auipc	a0,0x6
    80002b3a:	82a50513          	add	a0,a0,-2006 # 80008360 <states.0+0x78>
    80002b3e:	ffffe097          	auipc	ra,0xffffe
    80002b42:	a48080e7          	jalr	-1464(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b46:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b4a:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b4e:	00006517          	auipc	a0,0x6
    80002b52:	84250513          	add	a0,a0,-1982 # 80008390 <states.0+0xa8>
    80002b56:	ffffe097          	auipc	ra,0xffffe
    80002b5a:	a30080e7          	jalr	-1488(ra) # 80000586 <printf>
    setkilled(p);
    80002b5e:	8526                	mv	a0,s1
    80002b60:	00000097          	auipc	ra,0x0
    80002b64:	9d4080e7          	jalr	-1580(ra) # 80002534 <setkilled>
    80002b68:	b79d                	j	80002ace <usertrap+0x46>
    exit(-1);
    80002b6a:	557d                	li	a0,-1
    80002b6c:	00000097          	auipc	ra,0x0
    80002b70:	874080e7          	jalr	-1932(ra) # 800023e0 <exit>
    80002b74:	b79d                	j	80002ada <usertrap+0x52>

0000000080002b76 <kerneltrap>:
{
    80002b76:	7179                	add	sp,sp,-48
    80002b78:	f406                	sd	ra,40(sp)
    80002b7a:	f022                	sd	s0,32(sp)
    80002b7c:	ec26                	sd	s1,24(sp)
    80002b7e:	e84a                	sd	s2,16(sp)
    80002b80:	e44e                	sd	s3,8(sp)
    80002b82:	1800                	add	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b84:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b88:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b8c:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002b90:	1004f793          	and	a5,s1,256
    80002b94:	c78d                	beqz	a5,80002bbe <kerneltrap+0x48>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b96:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002b9a:	8b89                	and	a5,a5,2
  if(intr_get() != 0)
    80002b9c:	eb8d                	bnez	a5,80002bce <kerneltrap+0x58>
  if((which_dev = devintr()) == 0){
    80002b9e:	00000097          	auipc	ra,0x0
    80002ba2:	e44080e7          	jalr	-444(ra) # 800029e2 <devintr>
    80002ba6:	cd05                	beqz	a0,80002bde <kerneltrap+0x68>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002ba8:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bac:	10049073          	csrw	sstatus,s1
}
    80002bb0:	70a2                	ld	ra,40(sp)
    80002bb2:	7402                	ld	s0,32(sp)
    80002bb4:	64e2                	ld	s1,24(sp)
    80002bb6:	6942                	ld	s2,16(sp)
    80002bb8:	69a2                	ld	s3,8(sp)
    80002bba:	6145                	add	sp,sp,48
    80002bbc:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002bbe:	00005517          	auipc	a0,0x5
    80002bc2:	7f250513          	add	a0,a0,2034 # 800083b0 <states.0+0xc8>
    80002bc6:	ffffe097          	auipc	ra,0xffffe
    80002bca:	976080e7          	jalr	-1674(ra) # 8000053c <panic>
    panic("kerneltrap: interrupts enabled");
    80002bce:	00006517          	auipc	a0,0x6
    80002bd2:	80a50513          	add	a0,a0,-2038 # 800083d8 <states.0+0xf0>
    80002bd6:	ffffe097          	auipc	ra,0xffffe
    80002bda:	966080e7          	jalr	-1690(ra) # 8000053c <panic>
    printf("scause %p\n", scause);
    80002bde:	85ce                	mv	a1,s3
    80002be0:	00006517          	auipc	a0,0x6
    80002be4:	81850513          	add	a0,a0,-2024 # 800083f8 <states.0+0x110>
    80002be8:	ffffe097          	auipc	ra,0xffffe
    80002bec:	99e080e7          	jalr	-1634(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bf0:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002bf4:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002bf8:	00006517          	auipc	a0,0x6
    80002bfc:	81050513          	add	a0,a0,-2032 # 80008408 <states.0+0x120>
    80002c00:	ffffe097          	auipc	ra,0xffffe
    80002c04:	986080e7          	jalr	-1658(ra) # 80000586 <printf>
    panic("kerneltrap");
    80002c08:	00006517          	auipc	a0,0x6
    80002c0c:	81850513          	add	a0,a0,-2024 # 80008420 <states.0+0x138>
    80002c10:	ffffe097          	auipc	ra,0xffffe
    80002c14:	92c080e7          	jalr	-1748(ra) # 8000053c <panic>

0000000080002c18 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002c18:	1101                	add	sp,sp,-32
    80002c1a:	ec06                	sd	ra,24(sp)
    80002c1c:	e822                	sd	s0,16(sp)
    80002c1e:	e426                	sd	s1,8(sp)
    80002c20:	1000                	add	s0,sp,32
    80002c22:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002c24:	fffff097          	auipc	ra,0xfffff
    80002c28:	d82080e7          	jalr	-638(ra) # 800019a6 <myproc>
  switch (n) {
    80002c2c:	4795                	li	a5,5
    80002c2e:	0497e163          	bltu	a5,s1,80002c70 <argraw+0x58>
    80002c32:	048a                	sll	s1,s1,0x2
    80002c34:	00006717          	auipc	a4,0x6
    80002c38:	96470713          	add	a4,a4,-1692 # 80008598 <states.0+0x2b0>
    80002c3c:	94ba                	add	s1,s1,a4
    80002c3e:	409c                	lw	a5,0(s1)
    80002c40:	97ba                	add	a5,a5,a4
    80002c42:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002c44:	6d3c                	ld	a5,88(a0)
    80002c46:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002c48:	60e2                	ld	ra,24(sp)
    80002c4a:	6442                	ld	s0,16(sp)
    80002c4c:	64a2                	ld	s1,8(sp)
    80002c4e:	6105                	add	sp,sp,32
    80002c50:	8082                	ret
    return p->trapframe->a1;
    80002c52:	6d3c                	ld	a5,88(a0)
    80002c54:	7fa8                	ld	a0,120(a5)
    80002c56:	bfcd                	j	80002c48 <argraw+0x30>
    return p->trapframe->a2;
    80002c58:	6d3c                	ld	a5,88(a0)
    80002c5a:	63c8                	ld	a0,128(a5)
    80002c5c:	b7f5                	j	80002c48 <argraw+0x30>
    return p->trapframe->a3;
    80002c5e:	6d3c                	ld	a5,88(a0)
    80002c60:	67c8                	ld	a0,136(a5)
    80002c62:	b7dd                	j	80002c48 <argraw+0x30>
    return p->trapframe->a4;
    80002c64:	6d3c                	ld	a5,88(a0)
    80002c66:	6bc8                	ld	a0,144(a5)
    80002c68:	b7c5                	j	80002c48 <argraw+0x30>
    return p->trapframe->a5;
    80002c6a:	6d3c                	ld	a5,88(a0)
    80002c6c:	6fc8                	ld	a0,152(a5)
    80002c6e:	bfe9                	j	80002c48 <argraw+0x30>
  panic("argraw");
    80002c70:	00005517          	auipc	a0,0x5
    80002c74:	7c050513          	add	a0,a0,1984 # 80008430 <states.0+0x148>
    80002c78:	ffffe097          	auipc	ra,0xffffe
    80002c7c:	8c4080e7          	jalr	-1852(ra) # 8000053c <panic>

0000000080002c80 <fetchaddr>:
{
    80002c80:	1101                	add	sp,sp,-32
    80002c82:	ec06                	sd	ra,24(sp)
    80002c84:	e822                	sd	s0,16(sp)
    80002c86:	e426                	sd	s1,8(sp)
    80002c88:	e04a                	sd	s2,0(sp)
    80002c8a:	1000                	add	s0,sp,32
    80002c8c:	84aa                	mv	s1,a0
    80002c8e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002c90:	fffff097          	auipc	ra,0xfffff
    80002c94:	d16080e7          	jalr	-746(ra) # 800019a6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002c98:	653c                	ld	a5,72(a0)
    80002c9a:	02f4f863          	bgeu	s1,a5,80002cca <fetchaddr+0x4a>
    80002c9e:	00848713          	add	a4,s1,8
    80002ca2:	02e7e663          	bltu	a5,a4,80002cce <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002ca6:	46a1                	li	a3,8
    80002ca8:	8626                	mv	a2,s1
    80002caa:	85ca                	mv	a1,s2
    80002cac:	6928                	ld	a0,80(a0)
    80002cae:	fffff097          	auipc	ra,0xfffff
    80002cb2:	a44080e7          	jalr	-1468(ra) # 800016f2 <copyin>
    80002cb6:	00a03533          	snez	a0,a0
    80002cba:	40a00533          	neg	a0,a0
}
    80002cbe:	60e2                	ld	ra,24(sp)
    80002cc0:	6442                	ld	s0,16(sp)
    80002cc2:	64a2                	ld	s1,8(sp)
    80002cc4:	6902                	ld	s2,0(sp)
    80002cc6:	6105                	add	sp,sp,32
    80002cc8:	8082                	ret
    return -1;
    80002cca:	557d                	li	a0,-1
    80002ccc:	bfcd                	j	80002cbe <fetchaddr+0x3e>
    80002cce:	557d                	li	a0,-1
    80002cd0:	b7fd                	j	80002cbe <fetchaddr+0x3e>

0000000080002cd2 <fetchstr>:
{
    80002cd2:	7179                	add	sp,sp,-48
    80002cd4:	f406                	sd	ra,40(sp)
    80002cd6:	f022                	sd	s0,32(sp)
    80002cd8:	ec26                	sd	s1,24(sp)
    80002cda:	e84a                	sd	s2,16(sp)
    80002cdc:	e44e                	sd	s3,8(sp)
    80002cde:	1800                	add	s0,sp,48
    80002ce0:	892a                	mv	s2,a0
    80002ce2:	84ae                	mv	s1,a1
    80002ce4:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002ce6:	fffff097          	auipc	ra,0xfffff
    80002cea:	cc0080e7          	jalr	-832(ra) # 800019a6 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002cee:	86ce                	mv	a3,s3
    80002cf0:	864a                	mv	a2,s2
    80002cf2:	85a6                	mv	a1,s1
    80002cf4:	6928                	ld	a0,80(a0)
    80002cf6:	fffff097          	auipc	ra,0xfffff
    80002cfa:	a8a080e7          	jalr	-1398(ra) # 80001780 <copyinstr>
  if(err < 0)
    80002cfe:	00054763          	bltz	a0,80002d0c <fetchstr+0x3a>
  return strlen(buf);
    80002d02:	8526                	mv	a0,s1
    80002d04:	ffffe097          	auipc	ra,0xffffe
    80002d08:	144080e7          	jalr	324(ra) # 80000e48 <strlen>
}
    80002d0c:	70a2                	ld	ra,40(sp)
    80002d0e:	7402                	ld	s0,32(sp)
    80002d10:	64e2                	ld	s1,24(sp)
    80002d12:	6942                	ld	s2,16(sp)
    80002d14:	69a2                	ld	s3,8(sp)
    80002d16:	6145                	add	sp,sp,48
    80002d18:	8082                	ret

0000000080002d1a <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002d1a:	1101                	add	sp,sp,-32
    80002d1c:	ec06                	sd	ra,24(sp)
    80002d1e:	e822                	sd	s0,16(sp)
    80002d20:	e426                	sd	s1,8(sp)
    80002d22:	1000                	add	s0,sp,32
    80002d24:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d26:	00000097          	auipc	ra,0x0
    80002d2a:	ef2080e7          	jalr	-270(ra) # 80002c18 <argraw>
    80002d2e:	c088                	sw	a0,0(s1)
  return 0;
}
    80002d30:	4501                	li	a0,0
    80002d32:	60e2                	ld	ra,24(sp)
    80002d34:	6442                	ld	s0,16(sp)
    80002d36:	64a2                	ld	s1,8(sp)
    80002d38:	6105                	add	sp,sp,32
    80002d3a:	8082                	ret

0000000080002d3c <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002d3c:	1101                	add	sp,sp,-32
    80002d3e:	ec06                	sd	ra,24(sp)
    80002d40:	e822                	sd	s0,16(sp)
    80002d42:	e426                	sd	s1,8(sp)
    80002d44:	1000                	add	s0,sp,32
    80002d46:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d48:	00000097          	auipc	ra,0x0
    80002d4c:	ed0080e7          	jalr	-304(ra) # 80002c18 <argraw>
    80002d50:	e088                	sd	a0,0(s1)
  return 0;
}
    80002d52:	4501                	li	a0,0
    80002d54:	60e2                	ld	ra,24(sp)
    80002d56:	6442                	ld	s0,16(sp)
    80002d58:	64a2                	ld	s1,8(sp)
    80002d5a:	6105                	add	sp,sp,32
    80002d5c:	8082                	ret

0000000080002d5e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002d5e:	1101                	add	sp,sp,-32
    80002d60:	ec06                	sd	ra,24(sp)
    80002d62:	e822                	sd	s0,16(sp)
    80002d64:	e426                	sd	s1,8(sp)
    80002d66:	e04a                	sd	s2,0(sp)
    80002d68:	1000                	add	s0,sp,32
    80002d6a:	84ae                	mv	s1,a1
    80002d6c:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002d6e:	00000097          	auipc	ra,0x0
    80002d72:	eaa080e7          	jalr	-342(ra) # 80002c18 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002d76:	864a                	mv	a2,s2
    80002d78:	85a6                	mv	a1,s1
    80002d7a:	00000097          	auipc	ra,0x0
    80002d7e:	f58080e7          	jalr	-168(ra) # 80002cd2 <fetchstr>
}
    80002d82:	60e2                	ld	ra,24(sp)
    80002d84:	6442                	ld	s0,16(sp)
    80002d86:	64a2                	ld	s1,8(sp)
    80002d88:	6902                	ld	s2,0(sp)
    80002d8a:	6105                	add	sp,sp,32
    80002d8c:	8082                	ret

0000000080002d8e <syscall>:

int syscall_args_num[] = {0, 0, 1, 1, 1, 3, 1, 2, 2, 1, 1, 0, 1, 1, 0, 2, 3, 2, 1, 2, 1, 1, 3, 1, 2};

void
syscall(void)
{
    80002d8e:	7179                	add	sp,sp,-48
    80002d90:	f406                	sd	ra,40(sp)
    80002d92:	f022                	sd	s0,32(sp)
    80002d94:	ec26                	sd	s1,24(sp)
    80002d96:	e84a                	sd	s2,16(sp)
    80002d98:	e44e                	sd	s3,8(sp)
    80002d9a:	e052                	sd	s4,0(sp)
    80002d9c:	1800                	add	s0,sp,48
  int num;
  struct proc *p = myproc();
    80002d9e:	fffff097          	auipc	ra,0xfffff
    80002da2:	c08080e7          	jalr	-1016(ra) # 800019a6 <myproc>
    80002da6:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002da8:	05853903          	ld	s2,88(a0)
    80002dac:	0a893783          	ld	a5,168(s2)
    80002db0:	0007899b          	sext.w	s3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002db4:	37fd                	addw	a5,a5,-1
    80002db6:	475d                	li	a4,23
    80002db8:	0ef76a63          	bltu	a4,a5,80002eac <syscall+0x11e>
    80002dbc:	00399713          	sll	a4,s3,0x3
    80002dc0:	00005797          	auipc	a5,0x5
    80002dc4:	7f078793          	add	a5,a5,2032 # 800085b0 <syscalls>
    80002dc8:	97ba                	add	a5,a5,a4
    80002dca:	639c                	ld	a5,0(a5)
    80002dcc:	c3e5                	beqz	a5,80002eac <syscall+0x11e>
    int first_arg = p->trapframe->a0;
    80002dce:	07093a03          	ld	s4,112(s2)
    p->trapframe->a0 = syscalls[num]();
    80002dd2:	9782                	jalr	a5
    80002dd4:	06a93823          	sd	a0,112(s2)
    int m = p->mask;
    if ((m >> num) & 1) {
    80002dd8:	1684a783          	lw	a5,360(s1)
    80002ddc:	4137d7bb          	sraw	a5,a5,s3
    80002de0:	8b85                	and	a5,a5,1
    80002de2:	c7e5                	beqz	a5,80002eca <syscall+0x13c>
      if (syscall_args_num[num] == 0)
    80002de4:	00299713          	sll	a4,s3,0x2
    80002de8:	00006797          	auipc	a5,0x6
    80002dec:	c1078793          	add	a5,a5,-1008 # 800089f8 <syscall_args_num>
    80002df0:	97ba                	add	a5,a5,a4
    80002df2:	439c                	lw	a5,0(a5)
    80002df4:	c3b1                	beqz	a5,80002e38 <syscall+0xaa>
    int first_arg = p->trapframe->a0;
    80002df6:	000a069b          	sext.w	a3,s4
        printf("%d: syscall %s -> %d\n", p->pid, syscall_names[num], p->trapframe->a0);
      else if (syscall_args_num[num] == 1)
    80002dfa:	4705                	li	a4,1
    80002dfc:	06e78163          	beq	a5,a4,80002e5e <syscall+0xd0>
        printf("%d: syscall %s (%d) -> %d\n", p->pid, syscall_names[num], first_arg, p->trapframe->a0);
      else if (syscall_args_num[num] == 2)
    80002e00:	4709                	li	a4,2
    80002e02:	08e78163          	beq	a5,a4,80002e84 <syscall+0xf6>
        printf("%d: syscall %s (%d %d) -> %d\n", p->pid, syscall_names[num], first_arg, p->trapframe->a1, p->trapframe->a0);
      else if (syscall_args_num[num] == 3)
    80002e06:	470d                	li	a4,3
    80002e08:	0ce79163          	bne	a5,a4,80002eca <syscall+0x13c>
        printf("%d: syscall %s (%d %d %d) -> %d\n", p->pid, syscall_names[num], first_arg, p->trapframe->a1, p->trapframe->a2, p->trapframe->a0);
    80002e0c:	6cb8                	ld	a4,88(s1)
    80002e0e:	098e                	sll	s3,s3,0x3
    80002e10:	00006617          	auipc	a2,0x6
    80002e14:	be860613          	add	a2,a2,-1048 # 800089f8 <syscall_args_num>
    80002e18:	964e                	add	a2,a2,s3
    80002e1a:	07073803          	ld	a6,112(a4)
    80002e1e:	635c                	ld	a5,128(a4)
    80002e20:	7f38                	ld	a4,120(a4)
    80002e22:	7630                	ld	a2,104(a2)
    80002e24:	588c                	lw	a1,48(s1)
    80002e26:	00005517          	auipc	a0,0x5
    80002e2a:	66a50513          	add	a0,a0,1642 # 80008490 <states.0+0x1a8>
    80002e2e:	ffffd097          	auipc	ra,0xffffd
    80002e32:	758080e7          	jalr	1880(ra) # 80000586 <printf>
    80002e36:	a851                	j	80002eca <syscall+0x13c>
        printf("%d: syscall %s -> %d\n", p->pid, syscall_names[num], p->trapframe->a0);
    80002e38:	6cb8                	ld	a4,88(s1)
    80002e3a:	098e                	sll	s3,s3,0x3
    80002e3c:	00006797          	auipc	a5,0x6
    80002e40:	bbc78793          	add	a5,a5,-1092 # 800089f8 <syscall_args_num>
    80002e44:	97ce                	add	a5,a5,s3
    80002e46:	7b34                	ld	a3,112(a4)
    80002e48:	77b0                	ld	a2,104(a5)
    80002e4a:	588c                	lw	a1,48(s1)
    80002e4c:	00005517          	auipc	a0,0x5
    80002e50:	5ec50513          	add	a0,a0,1516 # 80008438 <states.0+0x150>
    80002e54:	ffffd097          	auipc	ra,0xffffd
    80002e58:	732080e7          	jalr	1842(ra) # 80000586 <printf>
    80002e5c:	a0bd                	j	80002eca <syscall+0x13c>
        printf("%d: syscall %s (%d) -> %d\n", p->pid, syscall_names[num], first_arg, p->trapframe->a0);
    80002e5e:	6cb8                	ld	a4,88(s1)
    80002e60:	098e                	sll	s3,s3,0x3
    80002e62:	00006797          	auipc	a5,0x6
    80002e66:	b9678793          	add	a5,a5,-1130 # 800089f8 <syscall_args_num>
    80002e6a:	97ce                	add	a5,a5,s3
    80002e6c:	7b38                	ld	a4,112(a4)
    80002e6e:	77b0                	ld	a2,104(a5)
    80002e70:	588c                	lw	a1,48(s1)
    80002e72:	00005517          	auipc	a0,0x5
    80002e76:	5de50513          	add	a0,a0,1502 # 80008450 <states.0+0x168>
    80002e7a:	ffffd097          	auipc	ra,0xffffd
    80002e7e:	70c080e7          	jalr	1804(ra) # 80000586 <printf>
    80002e82:	a0a1                	j	80002eca <syscall+0x13c>
        printf("%d: syscall %s (%d %d) -> %d\n", p->pid, syscall_names[num], first_arg, p->trapframe->a1, p->trapframe->a0);
    80002e84:	6cb8                	ld	a4,88(s1)
    80002e86:	098e                	sll	s3,s3,0x3
    80002e88:	00006617          	auipc	a2,0x6
    80002e8c:	b7060613          	add	a2,a2,-1168 # 800089f8 <syscall_args_num>
    80002e90:	964e                	add	a2,a2,s3
    80002e92:	7b3c                	ld	a5,112(a4)
    80002e94:	7f38                	ld	a4,120(a4)
    80002e96:	7630                	ld	a2,104(a2)
    80002e98:	588c                	lw	a1,48(s1)
    80002e9a:	00005517          	auipc	a0,0x5
    80002e9e:	5d650513          	add	a0,a0,1494 # 80008470 <states.0+0x188>
    80002ea2:	ffffd097          	auipc	ra,0xffffd
    80002ea6:	6e4080e7          	jalr	1764(ra) # 80000586 <printf>
    80002eaa:	a005                	j	80002eca <syscall+0x13c>
    }
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002eac:	86ce                	mv	a3,s3
    80002eae:	15848613          	add	a2,s1,344
    80002eb2:	588c                	lw	a1,48(s1)
    80002eb4:	00005517          	auipc	a0,0x5
    80002eb8:	60450513          	add	a0,a0,1540 # 800084b8 <states.0+0x1d0>
    80002ebc:	ffffd097          	auipc	ra,0xffffd
    80002ec0:	6ca080e7          	jalr	1738(ra) # 80000586 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002ec4:	6cbc                	ld	a5,88(s1)
    80002ec6:	577d                	li	a4,-1
    80002ec8:	fbb8                	sd	a4,112(a5)
  }
}
    80002eca:	70a2                	ld	ra,40(sp)
    80002ecc:	7402                	ld	s0,32(sp)
    80002ece:	64e2                	ld	s1,24(sp)
    80002ed0:	6942                	ld	s2,16(sp)
    80002ed2:	69a2                	ld	s3,8(sp)
    80002ed4:	6a02                	ld	s4,0(sp)
    80002ed6:	6145                	add	sp,sp,48
    80002ed8:	8082                	ret

0000000080002eda <sys_strace>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_strace(void)
{
    80002eda:	1101                	add	sp,sp,-32
    80002edc:	ec06                	sd	ra,24(sp)
    80002ede:	e822                	sd	s0,16(sp)
    80002ee0:	1000                	add	s0,sp,32
  int trace_mask;

  argint(0, &trace_mask);
    80002ee2:	fec40593          	add	a1,s0,-20
    80002ee6:	4501                	li	a0,0
    80002ee8:	00000097          	auipc	ra,0x0
    80002eec:	e32080e7          	jalr	-462(ra) # 80002d1a <argint>
  if (trace_mask < 0)
    80002ef0:	fec42783          	lw	a5,-20(s0)
    return -1;
    80002ef4:	557d                	li	a0,-1
  if (trace_mask < 0)
    80002ef6:	0007cb63          	bltz	a5,80002f0c <sys_strace+0x32>

  struct proc *p = myproc();
    80002efa:	fffff097          	auipc	ra,0xfffff
    80002efe:	aac080e7          	jalr	-1364(ra) # 800019a6 <myproc>
  p->mask = trace_mask;
    80002f02:	fec42783          	lw	a5,-20(s0)
    80002f06:	16f52423          	sw	a5,360(a0)

  return 0;
    80002f0a:	4501                	li	a0,0
}
    80002f0c:	60e2                	ld	ra,24(sp)
    80002f0e:	6442                	ld	s0,16(sp)
    80002f10:	6105                	add	sp,sp,32
    80002f12:	8082                	ret

0000000080002f14 <sys_waitx>:
uint64	
sys_waitx(void)	
{	
    80002f14:	7139                	add	sp,sp,-64
    80002f16:	fc06                	sd	ra,56(sp)
    80002f18:	f822                	sd	s0,48(sp)
    80002f1a:	f426                	sd	s1,40(sp)
    80002f1c:	f04a                	sd	s2,32(sp)
    80002f1e:	0080                	add	s0,sp,64
  uint64 addr, addr1, addr2;	
  uint wtime, rtime;	
  if(argaddr(0, &addr) < 0)	
    80002f20:	fd840593          	add	a1,s0,-40
    80002f24:	4501                	li	a0,0
    80002f26:	00000097          	auipc	ra,0x0
    80002f2a:	e16080e7          	jalr	-490(ra) # 80002d3c <argaddr>
    return -1;	
    80002f2e:	57fd                	li	a5,-1
  if(argaddr(0, &addr) < 0)	
    80002f30:	08054063          	bltz	a0,80002fb0 <sys_waitx+0x9c>
  if(argaddr(1, &addr1) < 0) // user virtual memory	
    80002f34:	fd040593          	add	a1,s0,-48
    80002f38:	4505                	li	a0,1
    80002f3a:	00000097          	auipc	ra,0x0
    80002f3e:	e02080e7          	jalr	-510(ra) # 80002d3c <argaddr>
    return -1;	
    80002f42:	57fd                	li	a5,-1
  if(argaddr(1, &addr1) < 0) // user virtual memory	
    80002f44:	06054663          	bltz	a0,80002fb0 <sys_waitx+0x9c>
  if(argaddr(2, &addr2) < 0)	
    80002f48:	fc840593          	add	a1,s0,-56
    80002f4c:	4509                	li	a0,2
    80002f4e:	00000097          	auipc	ra,0x0
    80002f52:	dee080e7          	jalr	-530(ra) # 80002d3c <argaddr>
    return -1;	
    80002f56:	57fd                	li	a5,-1
  if(argaddr(2, &addr2) < 0)	
    80002f58:	04054c63          	bltz	a0,80002fb0 <sys_waitx+0x9c>
  int ret = waitx(addr, &wtime, &rtime);	
    80002f5c:	fc040613          	add	a2,s0,-64
    80002f60:	fc440593          	add	a1,s0,-60
    80002f64:	fd843503          	ld	a0,-40(s0)
    80002f68:	fffff097          	auipc	ra,0xfffff
    80002f6c:	25c080e7          	jalr	604(ra) # 800021c4 <waitx>
    80002f70:	892a                	mv	s2,a0
  struct proc* p = myproc();	
    80002f72:	fffff097          	auipc	ra,0xfffff
    80002f76:	a34080e7          	jalr	-1484(ra) # 800019a6 <myproc>
    80002f7a:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)	
    80002f7c:	4691                	li	a3,4
    80002f7e:	fc440613          	add	a2,s0,-60
    80002f82:	fd043583          	ld	a1,-48(s0)
    80002f86:	6928                	ld	a0,80(a0)
    80002f88:	ffffe097          	auipc	ra,0xffffe
    80002f8c:	6de080e7          	jalr	1758(ra) # 80001666 <copyout>
    return -1;	
    80002f90:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1,(char*)&wtime, sizeof(int)) < 0)	
    80002f92:	00054f63          	bltz	a0,80002fb0 <sys_waitx+0x9c>
  if (copyout(p->pagetable, addr2,(char*)&rtime, sizeof(int)) < 0)	
    80002f96:	4691                	li	a3,4
    80002f98:	fc040613          	add	a2,s0,-64
    80002f9c:	fc843583          	ld	a1,-56(s0)
    80002fa0:	68a8                	ld	a0,80(s1)
    80002fa2:	ffffe097          	auipc	ra,0xffffe
    80002fa6:	6c4080e7          	jalr	1732(ra) # 80001666 <copyout>
    80002faa:	00054a63          	bltz	a0,80002fbe <sys_waitx+0xaa>
    return -1;	
  return ret;	
    80002fae:	87ca                	mv	a5,s2
}	
    80002fb0:	853e                	mv	a0,a5
    80002fb2:	70e2                	ld	ra,56(sp)
    80002fb4:	7442                	ld	s0,48(sp)
    80002fb6:	74a2                	ld	s1,40(sp)
    80002fb8:	7902                	ld	s2,32(sp)
    80002fba:	6121                	add	sp,sp,64
    80002fbc:	8082                	ret
    return -1;	
    80002fbe:	57fd                	li	a5,-1
    80002fc0:	bfc5                	j	80002fb0 <sys_waitx+0x9c>

0000000080002fc2 <sys_set_priority>:
uint64	
sys_set_priority(void)	
{	
    80002fc2:	1101                	add	sp,sp,-32
    80002fc4:	ec06                	sd	ra,24(sp)
    80002fc6:	e822                	sd	s0,16(sp)
    80002fc8:	1000                	add	s0,sp,32
  int priority, pid;	
  if (argint(0, &priority) < 0)	
    80002fca:	fec40593          	add	a1,s0,-20
    80002fce:	4501                	li	a0,0
    80002fd0:	00000097          	auipc	ra,0x0
    80002fd4:	d4a080e7          	jalr	-694(ra) # 80002d1a <argint>
    return -1;	
    80002fd8:	57fd                	li	a5,-1
  if (argint(0, &priority) < 0)	
    80002fda:	02054563          	bltz	a0,80003004 <sys_set_priority+0x42>
  if (argint(1, &pid) < 0)	
    80002fde:	fe840593          	add	a1,s0,-24
    80002fe2:	4505                	li	a0,1
    80002fe4:	00000097          	auipc	ra,0x0
    80002fe8:	d36080e7          	jalr	-714(ra) # 80002d1a <argint>
    return -1;	
    80002fec:	57fd                	li	a5,-1
  if (argint(1, &pid) < 0)	
    80002fee:	00054b63          	bltz	a0,80003004 <sys_set_priority+0x42>
  return set_priority(priority, pid);	
    80002ff2:	fe842583          	lw	a1,-24(s0)
    80002ff6:	fec42503          	lw	a0,-20(s0)
    80002ffa:	fffff097          	auipc	ra,0xfffff
    80002ffe:	f5e080e7          	jalr	-162(ra) # 80001f58 <set_priority>
    80003002:	87aa                	mv	a5,a0
}
    80003004:	853e                	mv	a0,a5
    80003006:	60e2                	ld	ra,24(sp)
    80003008:	6442                	ld	s0,16(sp)
    8000300a:	6105                	add	sp,sp,32
    8000300c:	8082                	ret

000000008000300e <sys_exit>:
uint64
sys_exit(void)
{
    8000300e:	1101                	add	sp,sp,-32
    80003010:	ec06                	sd	ra,24(sp)
    80003012:	e822                	sd	s0,16(sp)
    80003014:	1000                	add	s0,sp,32
  int n;
  argint(0, &n);
    80003016:	fec40593          	add	a1,s0,-20
    8000301a:	4501                	li	a0,0
    8000301c:	00000097          	auipc	ra,0x0
    80003020:	cfe080e7          	jalr	-770(ra) # 80002d1a <argint>
  exit(n);
    80003024:	fec42503          	lw	a0,-20(s0)
    80003028:	fffff097          	auipc	ra,0xfffff
    8000302c:	3b8080e7          	jalr	952(ra) # 800023e0 <exit>
  return 0;  // not reached
}
    80003030:	4501                	li	a0,0
    80003032:	60e2                	ld	ra,24(sp)
    80003034:	6442                	ld	s0,16(sp)
    80003036:	6105                	add	sp,sp,32
    80003038:	8082                	ret

000000008000303a <sys_getpid>:

uint64
sys_getpid(void)
{
    8000303a:	1141                	add	sp,sp,-16
    8000303c:	e406                	sd	ra,8(sp)
    8000303e:	e022                	sd	s0,0(sp)
    80003040:	0800                	add	s0,sp,16
  return myproc()->pid;
    80003042:	fffff097          	auipc	ra,0xfffff
    80003046:	964080e7          	jalr	-1692(ra) # 800019a6 <myproc>
}
    8000304a:	5908                	lw	a0,48(a0)
    8000304c:	60a2                	ld	ra,8(sp)
    8000304e:	6402                	ld	s0,0(sp)
    80003050:	0141                	add	sp,sp,16
    80003052:	8082                	ret

0000000080003054 <sys_fork>:

uint64
sys_fork(void)
{
    80003054:	1141                	add	sp,sp,-16
    80003056:	e406                	sd	ra,8(sp)
    80003058:	e022                	sd	s0,0(sp)
    8000305a:	0800                	add	s0,sp,16
  return fork();
    8000305c:	fffff097          	auipc	ra,0xfffff
    80003060:	d1c080e7          	jalr	-740(ra) # 80001d78 <fork>
}
    80003064:	60a2                	ld	ra,8(sp)
    80003066:	6402                	ld	s0,0(sp)
    80003068:	0141                	add	sp,sp,16
    8000306a:	8082                	ret

000000008000306c <sys_wait>:

uint64
sys_wait(void)
{
    8000306c:	1101                	add	sp,sp,-32
    8000306e:	ec06                	sd	ra,24(sp)
    80003070:	e822                	sd	s0,16(sp)
    80003072:	1000                	add	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80003074:	fe840593          	add	a1,s0,-24
    80003078:	4501                	li	a0,0
    8000307a:	00000097          	auipc	ra,0x0
    8000307e:	cc2080e7          	jalr	-830(ra) # 80002d3c <argaddr>
  return wait(p);
    80003082:	fe843503          	ld	a0,-24(s0)
    80003086:	fffff097          	auipc	ra,0xfffff
    8000308a:	50c080e7          	jalr	1292(ra) # 80002592 <wait>
}
    8000308e:	60e2                	ld	ra,24(sp)
    80003090:	6442                	ld	s0,16(sp)
    80003092:	6105                	add	sp,sp,32
    80003094:	8082                	ret

0000000080003096 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003096:	7179                	add	sp,sp,-48
    80003098:	f406                	sd	ra,40(sp)
    8000309a:	f022                	sd	s0,32(sp)
    8000309c:	ec26                	sd	s1,24(sp)
    8000309e:	1800                	add	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    800030a0:	fdc40593          	add	a1,s0,-36
    800030a4:	4501                	li	a0,0
    800030a6:	00000097          	auipc	ra,0x0
    800030aa:	c74080e7          	jalr	-908(ra) # 80002d1a <argint>
  addr = myproc()->sz;
    800030ae:	fffff097          	auipc	ra,0xfffff
    800030b2:	8f8080e7          	jalr	-1800(ra) # 800019a6 <myproc>
    800030b6:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    800030b8:	fdc42503          	lw	a0,-36(s0)
    800030bc:	fffff097          	auipc	ra,0xfffff
    800030c0:	c60080e7          	jalr	-928(ra) # 80001d1c <growproc>
    800030c4:	00054863          	bltz	a0,800030d4 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    800030c8:	8526                	mv	a0,s1
    800030ca:	70a2                	ld	ra,40(sp)
    800030cc:	7402                	ld	s0,32(sp)
    800030ce:	64e2                	ld	s1,24(sp)
    800030d0:	6145                	add	sp,sp,48
    800030d2:	8082                	ret
    return -1;
    800030d4:	54fd                	li	s1,-1
    800030d6:	bfcd                	j	800030c8 <sys_sbrk+0x32>

00000000800030d8 <sys_sleep>:

uint64
sys_sleep(void)
{
    800030d8:	7139                	add	sp,sp,-64
    800030da:	fc06                	sd	ra,56(sp)
    800030dc:	f822                	sd	s0,48(sp)
    800030de:	f426                	sd	s1,40(sp)
    800030e0:	f04a                	sd	s2,32(sp)
    800030e2:	ec4e                	sd	s3,24(sp)
    800030e4:	0080                	add	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800030e6:	fcc40593          	add	a1,s0,-52
    800030ea:	4501                	li	a0,0
    800030ec:	00000097          	auipc	ra,0x0
    800030f0:	c2e080e7          	jalr	-978(ra) # 80002d1a <argint>
  acquire(&tickslock);
    800030f4:	00014517          	auipc	a0,0x14
    800030f8:	30c50513          	add	a0,a0,780 # 80017400 <tickslock>
    800030fc:	ffffe097          	auipc	ra,0xffffe
    80003100:	ad6080e7          	jalr	-1322(ra) # 80000bd2 <acquire>
  ticks0 = ticks;
    80003104:	00006917          	auipc	s2,0x6
    80003108:	a5c92903          	lw	s2,-1444(s2) # 80008b60 <ticks>
  while(ticks - ticks0 < n){
    8000310c:	fcc42783          	lw	a5,-52(s0)
    80003110:	cf9d                	beqz	a5,8000314e <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003112:	00014997          	auipc	s3,0x14
    80003116:	2ee98993          	add	s3,s3,750 # 80017400 <tickslock>
    8000311a:	00006497          	auipc	s1,0x6
    8000311e:	a4648493          	add	s1,s1,-1466 # 80008b60 <ticks>
    if(killed(myproc())){
    80003122:	fffff097          	auipc	ra,0xfffff
    80003126:	884080e7          	jalr	-1916(ra) # 800019a6 <myproc>
    8000312a:	fffff097          	auipc	ra,0xfffff
    8000312e:	436080e7          	jalr	1078(ra) # 80002560 <killed>
    80003132:	ed15                	bnez	a0,8000316e <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80003134:	85ce                	mv	a1,s3
    80003136:	8526                	mv	a0,s1
    80003138:	fffff097          	auipc	ra,0xfffff
    8000313c:	028080e7          	jalr	40(ra) # 80002160 <sleep>
  while(ticks - ticks0 < n){
    80003140:	409c                	lw	a5,0(s1)
    80003142:	412787bb          	subw	a5,a5,s2
    80003146:	fcc42703          	lw	a4,-52(s0)
    8000314a:	fce7ece3          	bltu	a5,a4,80003122 <sys_sleep+0x4a>
  }
  release(&tickslock);
    8000314e:	00014517          	auipc	a0,0x14
    80003152:	2b250513          	add	a0,a0,690 # 80017400 <tickslock>
    80003156:	ffffe097          	auipc	ra,0xffffe
    8000315a:	b30080e7          	jalr	-1232(ra) # 80000c86 <release>
  return 0;
    8000315e:	4501                	li	a0,0
}
    80003160:	70e2                	ld	ra,56(sp)
    80003162:	7442                	ld	s0,48(sp)
    80003164:	74a2                	ld	s1,40(sp)
    80003166:	7902                	ld	s2,32(sp)
    80003168:	69e2                	ld	s3,24(sp)
    8000316a:	6121                	add	sp,sp,64
    8000316c:	8082                	ret
      release(&tickslock);
    8000316e:	00014517          	auipc	a0,0x14
    80003172:	29250513          	add	a0,a0,658 # 80017400 <tickslock>
    80003176:	ffffe097          	auipc	ra,0xffffe
    8000317a:	b10080e7          	jalr	-1264(ra) # 80000c86 <release>
      return -1;
    8000317e:	557d                	li	a0,-1
    80003180:	b7c5                	j	80003160 <sys_sleep+0x88>

0000000080003182 <sys_kill>:

uint64
sys_kill(void)
{
    80003182:	1101                	add	sp,sp,-32
    80003184:	ec06                	sd	ra,24(sp)
    80003186:	e822                	sd	s0,16(sp)
    80003188:	1000                	add	s0,sp,32
  int pid;

  argint(0, &pid);
    8000318a:	fec40593          	add	a1,s0,-20
    8000318e:	4501                	li	a0,0
    80003190:	00000097          	auipc	ra,0x0
    80003194:	b8a080e7          	jalr	-1142(ra) # 80002d1a <argint>
  return kill(pid);
    80003198:	fec42503          	lw	a0,-20(s0)
    8000319c:	fffff097          	auipc	ra,0xfffff
    800031a0:	326080e7          	jalr	806(ra) # 800024c2 <kill>
}
    800031a4:	60e2                	ld	ra,24(sp)
    800031a6:	6442                	ld	s0,16(sp)
    800031a8:	6105                	add	sp,sp,32
    800031aa:	8082                	ret

00000000800031ac <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800031ac:	1101                	add	sp,sp,-32
    800031ae:	ec06                	sd	ra,24(sp)
    800031b0:	e822                	sd	s0,16(sp)
    800031b2:	e426                	sd	s1,8(sp)
    800031b4:	1000                	add	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800031b6:	00014517          	auipc	a0,0x14
    800031ba:	24a50513          	add	a0,a0,586 # 80017400 <tickslock>
    800031be:	ffffe097          	auipc	ra,0xffffe
    800031c2:	a14080e7          	jalr	-1516(ra) # 80000bd2 <acquire>
  xticks = ticks;
    800031c6:	00006497          	auipc	s1,0x6
    800031ca:	99a4a483          	lw	s1,-1638(s1) # 80008b60 <ticks>
  release(&tickslock);
    800031ce:	00014517          	auipc	a0,0x14
    800031d2:	23250513          	add	a0,a0,562 # 80017400 <tickslock>
    800031d6:	ffffe097          	auipc	ra,0xffffe
    800031da:	ab0080e7          	jalr	-1360(ra) # 80000c86 <release>
  return xticks;
}
    800031de:	02049513          	sll	a0,s1,0x20
    800031e2:	9101                	srl	a0,a0,0x20
    800031e4:	60e2                	ld	ra,24(sp)
    800031e6:	6442                	ld	s0,16(sp)
    800031e8:	64a2                	ld	s1,8(sp)
    800031ea:	6105                	add	sp,sp,32
    800031ec:	8082                	ret

00000000800031ee <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800031ee:	7179                	add	sp,sp,-48
    800031f0:	f406                	sd	ra,40(sp)
    800031f2:	f022                	sd	s0,32(sp)
    800031f4:	ec26                	sd	s1,24(sp)
    800031f6:	e84a                	sd	s2,16(sp)
    800031f8:	e44e                	sd	s3,8(sp)
    800031fa:	e052                	sd	s4,0(sp)
    800031fc:	1800                	add	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800031fe:	00005597          	auipc	a1,0x5
    80003202:	47a58593          	add	a1,a1,1146 # 80008678 <syscalls+0xc8>
    80003206:	00014517          	auipc	a0,0x14
    8000320a:	21250513          	add	a0,a0,530 # 80017418 <bcache>
    8000320e:	ffffe097          	auipc	ra,0xffffe
    80003212:	934080e7          	jalr	-1740(ra) # 80000b42 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003216:	0001c797          	auipc	a5,0x1c
    8000321a:	20278793          	add	a5,a5,514 # 8001f418 <bcache+0x8000>
    8000321e:	0001c717          	auipc	a4,0x1c
    80003222:	46270713          	add	a4,a4,1122 # 8001f680 <bcache+0x8268>
    80003226:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000322a:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000322e:	00014497          	auipc	s1,0x14
    80003232:	20248493          	add	s1,s1,514 # 80017430 <bcache+0x18>
    b->next = bcache.head.next;
    80003236:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003238:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000323a:	00005a17          	auipc	s4,0x5
    8000323e:	446a0a13          	add	s4,s4,1094 # 80008680 <syscalls+0xd0>
    b->next = bcache.head.next;
    80003242:	2b893783          	ld	a5,696(s2)
    80003246:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003248:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000324c:	85d2                	mv	a1,s4
    8000324e:	01048513          	add	a0,s1,16
    80003252:	00001097          	auipc	ra,0x1
    80003256:	496080e7          	jalr	1174(ra) # 800046e8 <initsleeplock>
    bcache.head.next->prev = b;
    8000325a:	2b893783          	ld	a5,696(s2)
    8000325e:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003260:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003264:	45848493          	add	s1,s1,1112
    80003268:	fd349de3          	bne	s1,s3,80003242 <binit+0x54>
  }
}
    8000326c:	70a2                	ld	ra,40(sp)
    8000326e:	7402                	ld	s0,32(sp)
    80003270:	64e2                	ld	s1,24(sp)
    80003272:	6942                	ld	s2,16(sp)
    80003274:	69a2                	ld	s3,8(sp)
    80003276:	6a02                	ld	s4,0(sp)
    80003278:	6145                	add	sp,sp,48
    8000327a:	8082                	ret

000000008000327c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000327c:	7179                	add	sp,sp,-48
    8000327e:	f406                	sd	ra,40(sp)
    80003280:	f022                	sd	s0,32(sp)
    80003282:	ec26                	sd	s1,24(sp)
    80003284:	e84a                	sd	s2,16(sp)
    80003286:	e44e                	sd	s3,8(sp)
    80003288:	1800                	add	s0,sp,48
    8000328a:	892a                	mv	s2,a0
    8000328c:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000328e:	00014517          	auipc	a0,0x14
    80003292:	18a50513          	add	a0,a0,394 # 80017418 <bcache>
    80003296:	ffffe097          	auipc	ra,0xffffe
    8000329a:	93c080e7          	jalr	-1732(ra) # 80000bd2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000329e:	0001c497          	auipc	s1,0x1c
    800032a2:	4324b483          	ld	s1,1074(s1) # 8001f6d0 <bcache+0x82b8>
    800032a6:	0001c797          	auipc	a5,0x1c
    800032aa:	3da78793          	add	a5,a5,986 # 8001f680 <bcache+0x8268>
    800032ae:	02f48f63          	beq	s1,a5,800032ec <bread+0x70>
    800032b2:	873e                	mv	a4,a5
    800032b4:	a021                	j	800032bc <bread+0x40>
    800032b6:	68a4                	ld	s1,80(s1)
    800032b8:	02e48a63          	beq	s1,a4,800032ec <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800032bc:	449c                	lw	a5,8(s1)
    800032be:	ff279ce3          	bne	a5,s2,800032b6 <bread+0x3a>
    800032c2:	44dc                	lw	a5,12(s1)
    800032c4:	ff3799e3          	bne	a5,s3,800032b6 <bread+0x3a>
      b->refcnt++;
    800032c8:	40bc                	lw	a5,64(s1)
    800032ca:	2785                	addw	a5,a5,1
    800032cc:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800032ce:	00014517          	auipc	a0,0x14
    800032d2:	14a50513          	add	a0,a0,330 # 80017418 <bcache>
    800032d6:	ffffe097          	auipc	ra,0xffffe
    800032da:	9b0080e7          	jalr	-1616(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    800032de:	01048513          	add	a0,s1,16
    800032e2:	00001097          	auipc	ra,0x1
    800032e6:	440080e7          	jalr	1088(ra) # 80004722 <acquiresleep>
      return b;
    800032ea:	a8b9                	j	80003348 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800032ec:	0001c497          	auipc	s1,0x1c
    800032f0:	3dc4b483          	ld	s1,988(s1) # 8001f6c8 <bcache+0x82b0>
    800032f4:	0001c797          	auipc	a5,0x1c
    800032f8:	38c78793          	add	a5,a5,908 # 8001f680 <bcache+0x8268>
    800032fc:	00f48863          	beq	s1,a5,8000330c <bread+0x90>
    80003300:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003302:	40bc                	lw	a5,64(s1)
    80003304:	cf81                	beqz	a5,8000331c <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003306:	64a4                	ld	s1,72(s1)
    80003308:	fee49de3          	bne	s1,a4,80003302 <bread+0x86>
  panic("bget: no buffers");
    8000330c:	00005517          	auipc	a0,0x5
    80003310:	37c50513          	add	a0,a0,892 # 80008688 <syscalls+0xd8>
    80003314:	ffffd097          	auipc	ra,0xffffd
    80003318:	228080e7          	jalr	552(ra) # 8000053c <panic>
      b->dev = dev;
    8000331c:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003320:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003324:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003328:	4785                	li	a5,1
    8000332a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000332c:	00014517          	auipc	a0,0x14
    80003330:	0ec50513          	add	a0,a0,236 # 80017418 <bcache>
    80003334:	ffffe097          	auipc	ra,0xffffe
    80003338:	952080e7          	jalr	-1710(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    8000333c:	01048513          	add	a0,s1,16
    80003340:	00001097          	auipc	ra,0x1
    80003344:	3e2080e7          	jalr	994(ra) # 80004722 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003348:	409c                	lw	a5,0(s1)
    8000334a:	cb89                	beqz	a5,8000335c <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000334c:	8526                	mv	a0,s1
    8000334e:	70a2                	ld	ra,40(sp)
    80003350:	7402                	ld	s0,32(sp)
    80003352:	64e2                	ld	s1,24(sp)
    80003354:	6942                	ld	s2,16(sp)
    80003356:	69a2                	ld	s3,8(sp)
    80003358:	6145                	add	sp,sp,48
    8000335a:	8082                	ret
    virtio_disk_rw(b, 0);
    8000335c:	4581                	li	a1,0
    8000335e:	8526                	mv	a0,s1
    80003360:	00003097          	auipc	ra,0x3
    80003364:	f82080e7          	jalr	-126(ra) # 800062e2 <virtio_disk_rw>
    b->valid = 1;
    80003368:	4785                	li	a5,1
    8000336a:	c09c                	sw	a5,0(s1)
  return b;
    8000336c:	b7c5                	j	8000334c <bread+0xd0>

000000008000336e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000336e:	1101                	add	sp,sp,-32
    80003370:	ec06                	sd	ra,24(sp)
    80003372:	e822                	sd	s0,16(sp)
    80003374:	e426                	sd	s1,8(sp)
    80003376:	1000                	add	s0,sp,32
    80003378:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000337a:	0541                	add	a0,a0,16
    8000337c:	00001097          	auipc	ra,0x1
    80003380:	440080e7          	jalr	1088(ra) # 800047bc <holdingsleep>
    80003384:	cd01                	beqz	a0,8000339c <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003386:	4585                	li	a1,1
    80003388:	8526                	mv	a0,s1
    8000338a:	00003097          	auipc	ra,0x3
    8000338e:	f58080e7          	jalr	-168(ra) # 800062e2 <virtio_disk_rw>
}
    80003392:	60e2                	ld	ra,24(sp)
    80003394:	6442                	ld	s0,16(sp)
    80003396:	64a2                	ld	s1,8(sp)
    80003398:	6105                	add	sp,sp,32
    8000339a:	8082                	ret
    panic("bwrite");
    8000339c:	00005517          	auipc	a0,0x5
    800033a0:	30450513          	add	a0,a0,772 # 800086a0 <syscalls+0xf0>
    800033a4:	ffffd097          	auipc	ra,0xffffd
    800033a8:	198080e7          	jalr	408(ra) # 8000053c <panic>

00000000800033ac <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800033ac:	1101                	add	sp,sp,-32
    800033ae:	ec06                	sd	ra,24(sp)
    800033b0:	e822                	sd	s0,16(sp)
    800033b2:	e426                	sd	s1,8(sp)
    800033b4:	e04a                	sd	s2,0(sp)
    800033b6:	1000                	add	s0,sp,32
    800033b8:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800033ba:	01050913          	add	s2,a0,16
    800033be:	854a                	mv	a0,s2
    800033c0:	00001097          	auipc	ra,0x1
    800033c4:	3fc080e7          	jalr	1020(ra) # 800047bc <holdingsleep>
    800033c8:	c925                	beqz	a0,80003438 <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    800033ca:	854a                	mv	a0,s2
    800033cc:	00001097          	auipc	ra,0x1
    800033d0:	3ac080e7          	jalr	940(ra) # 80004778 <releasesleep>

  acquire(&bcache.lock);
    800033d4:	00014517          	auipc	a0,0x14
    800033d8:	04450513          	add	a0,a0,68 # 80017418 <bcache>
    800033dc:	ffffd097          	auipc	ra,0xffffd
    800033e0:	7f6080e7          	jalr	2038(ra) # 80000bd2 <acquire>
  b->refcnt--;
    800033e4:	40bc                	lw	a5,64(s1)
    800033e6:	37fd                	addw	a5,a5,-1
    800033e8:	0007871b          	sext.w	a4,a5
    800033ec:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800033ee:	e71d                	bnez	a4,8000341c <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800033f0:	68b8                	ld	a4,80(s1)
    800033f2:	64bc                	ld	a5,72(s1)
    800033f4:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800033f6:	68b8                	ld	a4,80(s1)
    800033f8:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800033fa:	0001c797          	auipc	a5,0x1c
    800033fe:	01e78793          	add	a5,a5,30 # 8001f418 <bcache+0x8000>
    80003402:	2b87b703          	ld	a4,696(a5)
    80003406:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003408:	0001c717          	auipc	a4,0x1c
    8000340c:	27870713          	add	a4,a4,632 # 8001f680 <bcache+0x8268>
    80003410:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003412:	2b87b703          	ld	a4,696(a5)
    80003416:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003418:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000341c:	00014517          	auipc	a0,0x14
    80003420:	ffc50513          	add	a0,a0,-4 # 80017418 <bcache>
    80003424:	ffffe097          	auipc	ra,0xffffe
    80003428:	862080e7          	jalr	-1950(ra) # 80000c86 <release>
}
    8000342c:	60e2                	ld	ra,24(sp)
    8000342e:	6442                	ld	s0,16(sp)
    80003430:	64a2                	ld	s1,8(sp)
    80003432:	6902                	ld	s2,0(sp)
    80003434:	6105                	add	sp,sp,32
    80003436:	8082                	ret
    panic("brelse");
    80003438:	00005517          	auipc	a0,0x5
    8000343c:	27050513          	add	a0,a0,624 # 800086a8 <syscalls+0xf8>
    80003440:	ffffd097          	auipc	ra,0xffffd
    80003444:	0fc080e7          	jalr	252(ra) # 8000053c <panic>

0000000080003448 <bpin>:

void
bpin(struct buf *b) {
    80003448:	1101                	add	sp,sp,-32
    8000344a:	ec06                	sd	ra,24(sp)
    8000344c:	e822                	sd	s0,16(sp)
    8000344e:	e426                	sd	s1,8(sp)
    80003450:	1000                	add	s0,sp,32
    80003452:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003454:	00014517          	auipc	a0,0x14
    80003458:	fc450513          	add	a0,a0,-60 # 80017418 <bcache>
    8000345c:	ffffd097          	auipc	ra,0xffffd
    80003460:	776080e7          	jalr	1910(ra) # 80000bd2 <acquire>
  b->refcnt++;
    80003464:	40bc                	lw	a5,64(s1)
    80003466:	2785                	addw	a5,a5,1
    80003468:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000346a:	00014517          	auipc	a0,0x14
    8000346e:	fae50513          	add	a0,a0,-82 # 80017418 <bcache>
    80003472:	ffffe097          	auipc	ra,0xffffe
    80003476:	814080e7          	jalr	-2028(ra) # 80000c86 <release>
}
    8000347a:	60e2                	ld	ra,24(sp)
    8000347c:	6442                	ld	s0,16(sp)
    8000347e:	64a2                	ld	s1,8(sp)
    80003480:	6105                	add	sp,sp,32
    80003482:	8082                	ret

0000000080003484 <bunpin>:

void
bunpin(struct buf *b) {
    80003484:	1101                	add	sp,sp,-32
    80003486:	ec06                	sd	ra,24(sp)
    80003488:	e822                	sd	s0,16(sp)
    8000348a:	e426                	sd	s1,8(sp)
    8000348c:	1000                	add	s0,sp,32
    8000348e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003490:	00014517          	auipc	a0,0x14
    80003494:	f8850513          	add	a0,a0,-120 # 80017418 <bcache>
    80003498:	ffffd097          	auipc	ra,0xffffd
    8000349c:	73a080e7          	jalr	1850(ra) # 80000bd2 <acquire>
  b->refcnt--;
    800034a0:	40bc                	lw	a5,64(s1)
    800034a2:	37fd                	addw	a5,a5,-1
    800034a4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800034a6:	00014517          	auipc	a0,0x14
    800034aa:	f7250513          	add	a0,a0,-142 # 80017418 <bcache>
    800034ae:	ffffd097          	auipc	ra,0xffffd
    800034b2:	7d8080e7          	jalr	2008(ra) # 80000c86 <release>
}
    800034b6:	60e2                	ld	ra,24(sp)
    800034b8:	6442                	ld	s0,16(sp)
    800034ba:	64a2                	ld	s1,8(sp)
    800034bc:	6105                	add	sp,sp,32
    800034be:	8082                	ret

00000000800034c0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800034c0:	1101                	add	sp,sp,-32
    800034c2:	ec06                	sd	ra,24(sp)
    800034c4:	e822                	sd	s0,16(sp)
    800034c6:	e426                	sd	s1,8(sp)
    800034c8:	e04a                	sd	s2,0(sp)
    800034ca:	1000                	add	s0,sp,32
    800034cc:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800034ce:	00d5d59b          	srlw	a1,a1,0xd
    800034d2:	0001c797          	auipc	a5,0x1c
    800034d6:	6227a783          	lw	a5,1570(a5) # 8001faf4 <sb+0x1c>
    800034da:	9dbd                	addw	a1,a1,a5
    800034dc:	00000097          	auipc	ra,0x0
    800034e0:	da0080e7          	jalr	-608(ra) # 8000327c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800034e4:	0074f713          	and	a4,s1,7
    800034e8:	4785                	li	a5,1
    800034ea:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800034ee:	14ce                	sll	s1,s1,0x33
    800034f0:	90d9                	srl	s1,s1,0x36
    800034f2:	00950733          	add	a4,a0,s1
    800034f6:	05874703          	lbu	a4,88(a4)
    800034fa:	00e7f6b3          	and	a3,a5,a4
    800034fe:	c69d                	beqz	a3,8000352c <bfree+0x6c>
    80003500:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003502:	94aa                	add	s1,s1,a0
    80003504:	fff7c793          	not	a5,a5
    80003508:	8f7d                	and	a4,a4,a5
    8000350a:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000350e:	00001097          	auipc	ra,0x1
    80003512:	0f6080e7          	jalr	246(ra) # 80004604 <log_write>
  brelse(bp);
    80003516:	854a                	mv	a0,s2
    80003518:	00000097          	auipc	ra,0x0
    8000351c:	e94080e7          	jalr	-364(ra) # 800033ac <brelse>
}
    80003520:	60e2                	ld	ra,24(sp)
    80003522:	6442                	ld	s0,16(sp)
    80003524:	64a2                	ld	s1,8(sp)
    80003526:	6902                	ld	s2,0(sp)
    80003528:	6105                	add	sp,sp,32
    8000352a:	8082                	ret
    panic("freeing free block");
    8000352c:	00005517          	auipc	a0,0x5
    80003530:	18450513          	add	a0,a0,388 # 800086b0 <syscalls+0x100>
    80003534:	ffffd097          	auipc	ra,0xffffd
    80003538:	008080e7          	jalr	8(ra) # 8000053c <panic>

000000008000353c <balloc>:
{
    8000353c:	711d                	add	sp,sp,-96
    8000353e:	ec86                	sd	ra,88(sp)
    80003540:	e8a2                	sd	s0,80(sp)
    80003542:	e4a6                	sd	s1,72(sp)
    80003544:	e0ca                	sd	s2,64(sp)
    80003546:	fc4e                	sd	s3,56(sp)
    80003548:	f852                	sd	s4,48(sp)
    8000354a:	f456                	sd	s5,40(sp)
    8000354c:	f05a                	sd	s6,32(sp)
    8000354e:	ec5e                	sd	s7,24(sp)
    80003550:	e862                	sd	s8,16(sp)
    80003552:	e466                	sd	s9,8(sp)
    80003554:	1080                	add	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003556:	0001c797          	auipc	a5,0x1c
    8000355a:	5867a783          	lw	a5,1414(a5) # 8001fadc <sb+0x4>
    8000355e:	cff5                	beqz	a5,8000365a <balloc+0x11e>
    80003560:	8baa                	mv	s7,a0
    80003562:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003564:	0001cb17          	auipc	s6,0x1c
    80003568:	574b0b13          	add	s6,s6,1396 # 8001fad8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000356c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000356e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003570:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003572:	6c89                	lui	s9,0x2
    80003574:	a061                	j	800035fc <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003576:	97ca                	add	a5,a5,s2
    80003578:	8e55                	or	a2,a2,a3
    8000357a:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000357e:	854a                	mv	a0,s2
    80003580:	00001097          	auipc	ra,0x1
    80003584:	084080e7          	jalr	132(ra) # 80004604 <log_write>
        brelse(bp);
    80003588:	854a                	mv	a0,s2
    8000358a:	00000097          	auipc	ra,0x0
    8000358e:	e22080e7          	jalr	-478(ra) # 800033ac <brelse>
  bp = bread(dev, bno);
    80003592:	85a6                	mv	a1,s1
    80003594:	855e                	mv	a0,s7
    80003596:	00000097          	auipc	ra,0x0
    8000359a:	ce6080e7          	jalr	-794(ra) # 8000327c <bread>
    8000359e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800035a0:	40000613          	li	a2,1024
    800035a4:	4581                	li	a1,0
    800035a6:	05850513          	add	a0,a0,88
    800035aa:	ffffd097          	auipc	ra,0xffffd
    800035ae:	724080e7          	jalr	1828(ra) # 80000cce <memset>
  log_write(bp);
    800035b2:	854a                	mv	a0,s2
    800035b4:	00001097          	auipc	ra,0x1
    800035b8:	050080e7          	jalr	80(ra) # 80004604 <log_write>
  brelse(bp);
    800035bc:	854a                	mv	a0,s2
    800035be:	00000097          	auipc	ra,0x0
    800035c2:	dee080e7          	jalr	-530(ra) # 800033ac <brelse>
}
    800035c6:	8526                	mv	a0,s1
    800035c8:	60e6                	ld	ra,88(sp)
    800035ca:	6446                	ld	s0,80(sp)
    800035cc:	64a6                	ld	s1,72(sp)
    800035ce:	6906                	ld	s2,64(sp)
    800035d0:	79e2                	ld	s3,56(sp)
    800035d2:	7a42                	ld	s4,48(sp)
    800035d4:	7aa2                	ld	s5,40(sp)
    800035d6:	7b02                	ld	s6,32(sp)
    800035d8:	6be2                	ld	s7,24(sp)
    800035da:	6c42                	ld	s8,16(sp)
    800035dc:	6ca2                	ld	s9,8(sp)
    800035de:	6125                	add	sp,sp,96
    800035e0:	8082                	ret
    brelse(bp);
    800035e2:	854a                	mv	a0,s2
    800035e4:	00000097          	auipc	ra,0x0
    800035e8:	dc8080e7          	jalr	-568(ra) # 800033ac <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800035ec:	015c87bb          	addw	a5,s9,s5
    800035f0:	00078a9b          	sext.w	s5,a5
    800035f4:	004b2703          	lw	a4,4(s6)
    800035f8:	06eaf163          	bgeu	s5,a4,8000365a <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    800035fc:	41fad79b          	sraw	a5,s5,0x1f
    80003600:	0137d79b          	srlw	a5,a5,0x13
    80003604:	015787bb          	addw	a5,a5,s5
    80003608:	40d7d79b          	sraw	a5,a5,0xd
    8000360c:	01cb2583          	lw	a1,28(s6)
    80003610:	9dbd                	addw	a1,a1,a5
    80003612:	855e                	mv	a0,s7
    80003614:	00000097          	auipc	ra,0x0
    80003618:	c68080e7          	jalr	-920(ra) # 8000327c <bread>
    8000361c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000361e:	004b2503          	lw	a0,4(s6)
    80003622:	000a849b          	sext.w	s1,s5
    80003626:	8762                	mv	a4,s8
    80003628:	faa4fde3          	bgeu	s1,a0,800035e2 <balloc+0xa6>
      m = 1 << (bi % 8);
    8000362c:	00777693          	and	a3,a4,7
    80003630:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003634:	41f7579b          	sraw	a5,a4,0x1f
    80003638:	01d7d79b          	srlw	a5,a5,0x1d
    8000363c:	9fb9                	addw	a5,a5,a4
    8000363e:	4037d79b          	sraw	a5,a5,0x3
    80003642:	00f90633          	add	a2,s2,a5
    80003646:	05864603          	lbu	a2,88(a2)
    8000364a:	00c6f5b3          	and	a1,a3,a2
    8000364e:	d585                	beqz	a1,80003576 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003650:	2705                	addw	a4,a4,1
    80003652:	2485                	addw	s1,s1,1
    80003654:	fd471ae3          	bne	a4,s4,80003628 <balloc+0xec>
    80003658:	b769                	j	800035e2 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    8000365a:	00005517          	auipc	a0,0x5
    8000365e:	06e50513          	add	a0,a0,110 # 800086c8 <syscalls+0x118>
    80003662:	ffffd097          	auipc	ra,0xffffd
    80003666:	f24080e7          	jalr	-220(ra) # 80000586 <printf>
  return 0;
    8000366a:	4481                	li	s1,0
    8000366c:	bfa9                	j	800035c6 <balloc+0x8a>

000000008000366e <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000366e:	7179                	add	sp,sp,-48
    80003670:	f406                	sd	ra,40(sp)
    80003672:	f022                	sd	s0,32(sp)
    80003674:	ec26                	sd	s1,24(sp)
    80003676:	e84a                	sd	s2,16(sp)
    80003678:	e44e                	sd	s3,8(sp)
    8000367a:	e052                	sd	s4,0(sp)
    8000367c:	1800                	add	s0,sp,48
    8000367e:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003680:	47ad                	li	a5,11
    80003682:	02b7e863          	bltu	a5,a1,800036b2 <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    80003686:	02059793          	sll	a5,a1,0x20
    8000368a:	01e7d593          	srl	a1,a5,0x1e
    8000368e:	00b504b3          	add	s1,a0,a1
    80003692:	0504a903          	lw	s2,80(s1)
    80003696:	06091e63          	bnez	s2,80003712 <bmap+0xa4>
      addr = balloc(ip->dev);
    8000369a:	4108                	lw	a0,0(a0)
    8000369c:	00000097          	auipc	ra,0x0
    800036a0:	ea0080e7          	jalr	-352(ra) # 8000353c <balloc>
    800036a4:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800036a8:	06090563          	beqz	s2,80003712 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    800036ac:	0524a823          	sw	s2,80(s1)
    800036b0:	a08d                	j	80003712 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    800036b2:	ff45849b          	addw	s1,a1,-12
    800036b6:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800036ba:	0ff00793          	li	a5,255
    800036be:	08e7e563          	bltu	a5,a4,80003748 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800036c2:	08052903          	lw	s2,128(a0)
    800036c6:	00091d63          	bnez	s2,800036e0 <bmap+0x72>
      addr = balloc(ip->dev);
    800036ca:	4108                	lw	a0,0(a0)
    800036cc:	00000097          	auipc	ra,0x0
    800036d0:	e70080e7          	jalr	-400(ra) # 8000353c <balloc>
    800036d4:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800036d8:	02090d63          	beqz	s2,80003712 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800036dc:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800036e0:	85ca                	mv	a1,s2
    800036e2:	0009a503          	lw	a0,0(s3)
    800036e6:	00000097          	auipc	ra,0x0
    800036ea:	b96080e7          	jalr	-1130(ra) # 8000327c <bread>
    800036ee:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800036f0:	05850793          	add	a5,a0,88
    if((addr = a[bn]) == 0){
    800036f4:	02049713          	sll	a4,s1,0x20
    800036f8:	01e75593          	srl	a1,a4,0x1e
    800036fc:	00b784b3          	add	s1,a5,a1
    80003700:	0004a903          	lw	s2,0(s1)
    80003704:	02090063          	beqz	s2,80003724 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003708:	8552                	mv	a0,s4
    8000370a:	00000097          	auipc	ra,0x0
    8000370e:	ca2080e7          	jalr	-862(ra) # 800033ac <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003712:	854a                	mv	a0,s2
    80003714:	70a2                	ld	ra,40(sp)
    80003716:	7402                	ld	s0,32(sp)
    80003718:	64e2                	ld	s1,24(sp)
    8000371a:	6942                	ld	s2,16(sp)
    8000371c:	69a2                	ld	s3,8(sp)
    8000371e:	6a02                	ld	s4,0(sp)
    80003720:	6145                	add	sp,sp,48
    80003722:	8082                	ret
      addr = balloc(ip->dev);
    80003724:	0009a503          	lw	a0,0(s3)
    80003728:	00000097          	auipc	ra,0x0
    8000372c:	e14080e7          	jalr	-492(ra) # 8000353c <balloc>
    80003730:	0005091b          	sext.w	s2,a0
      if(addr){
    80003734:	fc090ae3          	beqz	s2,80003708 <bmap+0x9a>
        a[bn] = addr;
    80003738:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000373c:	8552                	mv	a0,s4
    8000373e:	00001097          	auipc	ra,0x1
    80003742:	ec6080e7          	jalr	-314(ra) # 80004604 <log_write>
    80003746:	b7c9                	j	80003708 <bmap+0x9a>
  panic("bmap: out of range");
    80003748:	00005517          	auipc	a0,0x5
    8000374c:	f9850513          	add	a0,a0,-104 # 800086e0 <syscalls+0x130>
    80003750:	ffffd097          	auipc	ra,0xffffd
    80003754:	dec080e7          	jalr	-532(ra) # 8000053c <panic>

0000000080003758 <iget>:
{
    80003758:	7179                	add	sp,sp,-48
    8000375a:	f406                	sd	ra,40(sp)
    8000375c:	f022                	sd	s0,32(sp)
    8000375e:	ec26                	sd	s1,24(sp)
    80003760:	e84a                	sd	s2,16(sp)
    80003762:	e44e                	sd	s3,8(sp)
    80003764:	e052                	sd	s4,0(sp)
    80003766:	1800                	add	s0,sp,48
    80003768:	89aa                	mv	s3,a0
    8000376a:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000376c:	0001c517          	auipc	a0,0x1c
    80003770:	38c50513          	add	a0,a0,908 # 8001faf8 <itable>
    80003774:	ffffd097          	auipc	ra,0xffffd
    80003778:	45e080e7          	jalr	1118(ra) # 80000bd2 <acquire>
  empty = 0;
    8000377c:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000377e:	0001c497          	auipc	s1,0x1c
    80003782:	39248493          	add	s1,s1,914 # 8001fb10 <itable+0x18>
    80003786:	0001e697          	auipc	a3,0x1e
    8000378a:	e1a68693          	add	a3,a3,-486 # 800215a0 <log>
    8000378e:	a039                	j	8000379c <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003790:	02090b63          	beqz	s2,800037c6 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003794:	08848493          	add	s1,s1,136
    80003798:	02d48a63          	beq	s1,a3,800037cc <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000379c:	449c                	lw	a5,8(s1)
    8000379e:	fef059e3          	blez	a5,80003790 <iget+0x38>
    800037a2:	4098                	lw	a4,0(s1)
    800037a4:	ff3716e3          	bne	a4,s3,80003790 <iget+0x38>
    800037a8:	40d8                	lw	a4,4(s1)
    800037aa:	ff4713e3          	bne	a4,s4,80003790 <iget+0x38>
      ip->ref++;
    800037ae:	2785                	addw	a5,a5,1
    800037b0:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800037b2:	0001c517          	auipc	a0,0x1c
    800037b6:	34650513          	add	a0,a0,838 # 8001faf8 <itable>
    800037ba:	ffffd097          	auipc	ra,0xffffd
    800037be:	4cc080e7          	jalr	1228(ra) # 80000c86 <release>
      return ip;
    800037c2:	8926                	mv	s2,s1
    800037c4:	a03d                	j	800037f2 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800037c6:	f7f9                	bnez	a5,80003794 <iget+0x3c>
    800037c8:	8926                	mv	s2,s1
    800037ca:	b7e9                	j	80003794 <iget+0x3c>
  if(empty == 0)
    800037cc:	02090c63          	beqz	s2,80003804 <iget+0xac>
  ip->dev = dev;
    800037d0:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800037d4:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800037d8:	4785                	li	a5,1
    800037da:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800037de:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800037e2:	0001c517          	auipc	a0,0x1c
    800037e6:	31650513          	add	a0,a0,790 # 8001faf8 <itable>
    800037ea:	ffffd097          	auipc	ra,0xffffd
    800037ee:	49c080e7          	jalr	1180(ra) # 80000c86 <release>
}
    800037f2:	854a                	mv	a0,s2
    800037f4:	70a2                	ld	ra,40(sp)
    800037f6:	7402                	ld	s0,32(sp)
    800037f8:	64e2                	ld	s1,24(sp)
    800037fa:	6942                	ld	s2,16(sp)
    800037fc:	69a2                	ld	s3,8(sp)
    800037fe:	6a02                	ld	s4,0(sp)
    80003800:	6145                	add	sp,sp,48
    80003802:	8082                	ret
    panic("iget: no inodes");
    80003804:	00005517          	auipc	a0,0x5
    80003808:	ef450513          	add	a0,a0,-268 # 800086f8 <syscalls+0x148>
    8000380c:	ffffd097          	auipc	ra,0xffffd
    80003810:	d30080e7          	jalr	-720(ra) # 8000053c <panic>

0000000080003814 <fsinit>:
fsinit(int dev) {
    80003814:	7179                	add	sp,sp,-48
    80003816:	f406                	sd	ra,40(sp)
    80003818:	f022                	sd	s0,32(sp)
    8000381a:	ec26                	sd	s1,24(sp)
    8000381c:	e84a                	sd	s2,16(sp)
    8000381e:	e44e                	sd	s3,8(sp)
    80003820:	1800                	add	s0,sp,48
    80003822:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003824:	4585                	li	a1,1
    80003826:	00000097          	auipc	ra,0x0
    8000382a:	a56080e7          	jalr	-1450(ra) # 8000327c <bread>
    8000382e:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003830:	0001c997          	auipc	s3,0x1c
    80003834:	2a898993          	add	s3,s3,680 # 8001fad8 <sb>
    80003838:	02000613          	li	a2,32
    8000383c:	05850593          	add	a1,a0,88
    80003840:	854e                	mv	a0,s3
    80003842:	ffffd097          	auipc	ra,0xffffd
    80003846:	4e8080e7          	jalr	1256(ra) # 80000d2a <memmove>
  brelse(bp);
    8000384a:	8526                	mv	a0,s1
    8000384c:	00000097          	auipc	ra,0x0
    80003850:	b60080e7          	jalr	-1184(ra) # 800033ac <brelse>
  if(sb.magic != FSMAGIC)
    80003854:	0009a703          	lw	a4,0(s3)
    80003858:	102037b7          	lui	a5,0x10203
    8000385c:	04078793          	add	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003860:	02f71263          	bne	a4,a5,80003884 <fsinit+0x70>
  initlog(dev, &sb);
    80003864:	0001c597          	auipc	a1,0x1c
    80003868:	27458593          	add	a1,a1,628 # 8001fad8 <sb>
    8000386c:	854a                	mv	a0,s2
    8000386e:	00001097          	auipc	ra,0x1
    80003872:	b2c080e7          	jalr	-1236(ra) # 8000439a <initlog>
}
    80003876:	70a2                	ld	ra,40(sp)
    80003878:	7402                	ld	s0,32(sp)
    8000387a:	64e2                	ld	s1,24(sp)
    8000387c:	6942                	ld	s2,16(sp)
    8000387e:	69a2                	ld	s3,8(sp)
    80003880:	6145                	add	sp,sp,48
    80003882:	8082                	ret
    panic("invalid file system");
    80003884:	00005517          	auipc	a0,0x5
    80003888:	e8450513          	add	a0,a0,-380 # 80008708 <syscalls+0x158>
    8000388c:	ffffd097          	auipc	ra,0xffffd
    80003890:	cb0080e7          	jalr	-848(ra) # 8000053c <panic>

0000000080003894 <iinit>:
{
    80003894:	7179                	add	sp,sp,-48
    80003896:	f406                	sd	ra,40(sp)
    80003898:	f022                	sd	s0,32(sp)
    8000389a:	ec26                	sd	s1,24(sp)
    8000389c:	e84a                	sd	s2,16(sp)
    8000389e:	e44e                	sd	s3,8(sp)
    800038a0:	1800                	add	s0,sp,48
  initlock(&itable.lock, "itable");
    800038a2:	00005597          	auipc	a1,0x5
    800038a6:	e7e58593          	add	a1,a1,-386 # 80008720 <syscalls+0x170>
    800038aa:	0001c517          	auipc	a0,0x1c
    800038ae:	24e50513          	add	a0,a0,590 # 8001faf8 <itable>
    800038b2:	ffffd097          	auipc	ra,0xffffd
    800038b6:	290080e7          	jalr	656(ra) # 80000b42 <initlock>
  for(i = 0; i < NINODE; i++) {
    800038ba:	0001c497          	auipc	s1,0x1c
    800038be:	26648493          	add	s1,s1,614 # 8001fb20 <itable+0x28>
    800038c2:	0001e997          	auipc	s3,0x1e
    800038c6:	cee98993          	add	s3,s3,-786 # 800215b0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800038ca:	00005917          	auipc	s2,0x5
    800038ce:	e5e90913          	add	s2,s2,-418 # 80008728 <syscalls+0x178>
    800038d2:	85ca                	mv	a1,s2
    800038d4:	8526                	mv	a0,s1
    800038d6:	00001097          	auipc	ra,0x1
    800038da:	e12080e7          	jalr	-494(ra) # 800046e8 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800038de:	08848493          	add	s1,s1,136
    800038e2:	ff3498e3          	bne	s1,s3,800038d2 <iinit+0x3e>
}
    800038e6:	70a2                	ld	ra,40(sp)
    800038e8:	7402                	ld	s0,32(sp)
    800038ea:	64e2                	ld	s1,24(sp)
    800038ec:	6942                	ld	s2,16(sp)
    800038ee:	69a2                	ld	s3,8(sp)
    800038f0:	6145                	add	sp,sp,48
    800038f2:	8082                	ret

00000000800038f4 <ialloc>:
{
    800038f4:	7139                	add	sp,sp,-64
    800038f6:	fc06                	sd	ra,56(sp)
    800038f8:	f822                	sd	s0,48(sp)
    800038fa:	f426                	sd	s1,40(sp)
    800038fc:	f04a                	sd	s2,32(sp)
    800038fe:	ec4e                	sd	s3,24(sp)
    80003900:	e852                	sd	s4,16(sp)
    80003902:	e456                	sd	s5,8(sp)
    80003904:	e05a                	sd	s6,0(sp)
    80003906:	0080                	add	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003908:	0001c717          	auipc	a4,0x1c
    8000390c:	1dc72703          	lw	a4,476(a4) # 8001fae4 <sb+0xc>
    80003910:	4785                	li	a5,1
    80003912:	04e7f863          	bgeu	a5,a4,80003962 <ialloc+0x6e>
    80003916:	8aaa                	mv	s5,a0
    80003918:	8b2e                	mv	s6,a1
    8000391a:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000391c:	0001ca17          	auipc	s4,0x1c
    80003920:	1bca0a13          	add	s4,s4,444 # 8001fad8 <sb>
    80003924:	00495593          	srl	a1,s2,0x4
    80003928:	018a2783          	lw	a5,24(s4)
    8000392c:	9dbd                	addw	a1,a1,a5
    8000392e:	8556                	mv	a0,s5
    80003930:	00000097          	auipc	ra,0x0
    80003934:	94c080e7          	jalr	-1716(ra) # 8000327c <bread>
    80003938:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000393a:	05850993          	add	s3,a0,88
    8000393e:	00f97793          	and	a5,s2,15
    80003942:	079a                	sll	a5,a5,0x6
    80003944:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003946:	00099783          	lh	a5,0(s3)
    8000394a:	cf9d                	beqz	a5,80003988 <ialloc+0x94>
    brelse(bp);
    8000394c:	00000097          	auipc	ra,0x0
    80003950:	a60080e7          	jalr	-1440(ra) # 800033ac <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003954:	0905                	add	s2,s2,1
    80003956:	00ca2703          	lw	a4,12(s4)
    8000395a:	0009079b          	sext.w	a5,s2
    8000395e:	fce7e3e3          	bltu	a5,a4,80003924 <ialloc+0x30>
  printf("ialloc: no inodes\n");
    80003962:	00005517          	auipc	a0,0x5
    80003966:	dce50513          	add	a0,a0,-562 # 80008730 <syscalls+0x180>
    8000396a:	ffffd097          	auipc	ra,0xffffd
    8000396e:	c1c080e7          	jalr	-996(ra) # 80000586 <printf>
  return 0;
    80003972:	4501                	li	a0,0
}
    80003974:	70e2                	ld	ra,56(sp)
    80003976:	7442                	ld	s0,48(sp)
    80003978:	74a2                	ld	s1,40(sp)
    8000397a:	7902                	ld	s2,32(sp)
    8000397c:	69e2                	ld	s3,24(sp)
    8000397e:	6a42                	ld	s4,16(sp)
    80003980:	6aa2                	ld	s5,8(sp)
    80003982:	6b02                	ld	s6,0(sp)
    80003984:	6121                	add	sp,sp,64
    80003986:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003988:	04000613          	li	a2,64
    8000398c:	4581                	li	a1,0
    8000398e:	854e                	mv	a0,s3
    80003990:	ffffd097          	auipc	ra,0xffffd
    80003994:	33e080e7          	jalr	830(ra) # 80000cce <memset>
      dip->type = type;
    80003998:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000399c:	8526                	mv	a0,s1
    8000399e:	00001097          	auipc	ra,0x1
    800039a2:	c66080e7          	jalr	-922(ra) # 80004604 <log_write>
      brelse(bp);
    800039a6:	8526                	mv	a0,s1
    800039a8:	00000097          	auipc	ra,0x0
    800039ac:	a04080e7          	jalr	-1532(ra) # 800033ac <brelse>
      return iget(dev, inum);
    800039b0:	0009059b          	sext.w	a1,s2
    800039b4:	8556                	mv	a0,s5
    800039b6:	00000097          	auipc	ra,0x0
    800039ba:	da2080e7          	jalr	-606(ra) # 80003758 <iget>
    800039be:	bf5d                	j	80003974 <ialloc+0x80>

00000000800039c0 <iupdate>:
{
    800039c0:	1101                	add	sp,sp,-32
    800039c2:	ec06                	sd	ra,24(sp)
    800039c4:	e822                	sd	s0,16(sp)
    800039c6:	e426                	sd	s1,8(sp)
    800039c8:	e04a                	sd	s2,0(sp)
    800039ca:	1000                	add	s0,sp,32
    800039cc:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800039ce:	415c                	lw	a5,4(a0)
    800039d0:	0047d79b          	srlw	a5,a5,0x4
    800039d4:	0001c597          	auipc	a1,0x1c
    800039d8:	11c5a583          	lw	a1,284(a1) # 8001faf0 <sb+0x18>
    800039dc:	9dbd                	addw	a1,a1,a5
    800039de:	4108                	lw	a0,0(a0)
    800039e0:	00000097          	auipc	ra,0x0
    800039e4:	89c080e7          	jalr	-1892(ra) # 8000327c <bread>
    800039e8:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800039ea:	05850793          	add	a5,a0,88
    800039ee:	40d8                	lw	a4,4(s1)
    800039f0:	8b3d                	and	a4,a4,15
    800039f2:	071a                	sll	a4,a4,0x6
    800039f4:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800039f6:	04449703          	lh	a4,68(s1)
    800039fa:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800039fe:	04649703          	lh	a4,70(s1)
    80003a02:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003a06:	04849703          	lh	a4,72(s1)
    80003a0a:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003a0e:	04a49703          	lh	a4,74(s1)
    80003a12:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003a16:	44f8                	lw	a4,76(s1)
    80003a18:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003a1a:	03400613          	li	a2,52
    80003a1e:	05048593          	add	a1,s1,80
    80003a22:	00c78513          	add	a0,a5,12
    80003a26:	ffffd097          	auipc	ra,0xffffd
    80003a2a:	304080e7          	jalr	772(ra) # 80000d2a <memmove>
  log_write(bp);
    80003a2e:	854a                	mv	a0,s2
    80003a30:	00001097          	auipc	ra,0x1
    80003a34:	bd4080e7          	jalr	-1068(ra) # 80004604 <log_write>
  brelse(bp);
    80003a38:	854a                	mv	a0,s2
    80003a3a:	00000097          	auipc	ra,0x0
    80003a3e:	972080e7          	jalr	-1678(ra) # 800033ac <brelse>
}
    80003a42:	60e2                	ld	ra,24(sp)
    80003a44:	6442                	ld	s0,16(sp)
    80003a46:	64a2                	ld	s1,8(sp)
    80003a48:	6902                	ld	s2,0(sp)
    80003a4a:	6105                	add	sp,sp,32
    80003a4c:	8082                	ret

0000000080003a4e <idup>:
{
    80003a4e:	1101                	add	sp,sp,-32
    80003a50:	ec06                	sd	ra,24(sp)
    80003a52:	e822                	sd	s0,16(sp)
    80003a54:	e426                	sd	s1,8(sp)
    80003a56:	1000                	add	s0,sp,32
    80003a58:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003a5a:	0001c517          	auipc	a0,0x1c
    80003a5e:	09e50513          	add	a0,a0,158 # 8001faf8 <itable>
    80003a62:	ffffd097          	auipc	ra,0xffffd
    80003a66:	170080e7          	jalr	368(ra) # 80000bd2 <acquire>
  ip->ref++;
    80003a6a:	449c                	lw	a5,8(s1)
    80003a6c:	2785                	addw	a5,a5,1
    80003a6e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003a70:	0001c517          	auipc	a0,0x1c
    80003a74:	08850513          	add	a0,a0,136 # 8001faf8 <itable>
    80003a78:	ffffd097          	auipc	ra,0xffffd
    80003a7c:	20e080e7          	jalr	526(ra) # 80000c86 <release>
}
    80003a80:	8526                	mv	a0,s1
    80003a82:	60e2                	ld	ra,24(sp)
    80003a84:	6442                	ld	s0,16(sp)
    80003a86:	64a2                	ld	s1,8(sp)
    80003a88:	6105                	add	sp,sp,32
    80003a8a:	8082                	ret

0000000080003a8c <ilock>:
{
    80003a8c:	1101                	add	sp,sp,-32
    80003a8e:	ec06                	sd	ra,24(sp)
    80003a90:	e822                	sd	s0,16(sp)
    80003a92:	e426                	sd	s1,8(sp)
    80003a94:	e04a                	sd	s2,0(sp)
    80003a96:	1000                	add	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003a98:	c115                	beqz	a0,80003abc <ilock+0x30>
    80003a9a:	84aa                	mv	s1,a0
    80003a9c:	451c                	lw	a5,8(a0)
    80003a9e:	00f05f63          	blez	a5,80003abc <ilock+0x30>
  acquiresleep(&ip->lock);
    80003aa2:	0541                	add	a0,a0,16
    80003aa4:	00001097          	auipc	ra,0x1
    80003aa8:	c7e080e7          	jalr	-898(ra) # 80004722 <acquiresleep>
  if(ip->valid == 0){
    80003aac:	40bc                	lw	a5,64(s1)
    80003aae:	cf99                	beqz	a5,80003acc <ilock+0x40>
}
    80003ab0:	60e2                	ld	ra,24(sp)
    80003ab2:	6442                	ld	s0,16(sp)
    80003ab4:	64a2                	ld	s1,8(sp)
    80003ab6:	6902                	ld	s2,0(sp)
    80003ab8:	6105                	add	sp,sp,32
    80003aba:	8082                	ret
    panic("ilock");
    80003abc:	00005517          	auipc	a0,0x5
    80003ac0:	c8c50513          	add	a0,a0,-884 # 80008748 <syscalls+0x198>
    80003ac4:	ffffd097          	auipc	ra,0xffffd
    80003ac8:	a78080e7          	jalr	-1416(ra) # 8000053c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003acc:	40dc                	lw	a5,4(s1)
    80003ace:	0047d79b          	srlw	a5,a5,0x4
    80003ad2:	0001c597          	auipc	a1,0x1c
    80003ad6:	01e5a583          	lw	a1,30(a1) # 8001faf0 <sb+0x18>
    80003ada:	9dbd                	addw	a1,a1,a5
    80003adc:	4088                	lw	a0,0(s1)
    80003ade:	fffff097          	auipc	ra,0xfffff
    80003ae2:	79e080e7          	jalr	1950(ra) # 8000327c <bread>
    80003ae6:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003ae8:	05850593          	add	a1,a0,88
    80003aec:	40dc                	lw	a5,4(s1)
    80003aee:	8bbd                	and	a5,a5,15
    80003af0:	079a                	sll	a5,a5,0x6
    80003af2:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003af4:	00059783          	lh	a5,0(a1)
    80003af8:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003afc:	00259783          	lh	a5,2(a1)
    80003b00:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003b04:	00459783          	lh	a5,4(a1)
    80003b08:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003b0c:	00659783          	lh	a5,6(a1)
    80003b10:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003b14:	459c                	lw	a5,8(a1)
    80003b16:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003b18:	03400613          	li	a2,52
    80003b1c:	05b1                	add	a1,a1,12
    80003b1e:	05048513          	add	a0,s1,80
    80003b22:	ffffd097          	auipc	ra,0xffffd
    80003b26:	208080e7          	jalr	520(ra) # 80000d2a <memmove>
    brelse(bp);
    80003b2a:	854a                	mv	a0,s2
    80003b2c:	00000097          	auipc	ra,0x0
    80003b30:	880080e7          	jalr	-1920(ra) # 800033ac <brelse>
    ip->valid = 1;
    80003b34:	4785                	li	a5,1
    80003b36:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003b38:	04449783          	lh	a5,68(s1)
    80003b3c:	fbb5                	bnez	a5,80003ab0 <ilock+0x24>
      panic("ilock: no type");
    80003b3e:	00005517          	auipc	a0,0x5
    80003b42:	c1250513          	add	a0,a0,-1006 # 80008750 <syscalls+0x1a0>
    80003b46:	ffffd097          	auipc	ra,0xffffd
    80003b4a:	9f6080e7          	jalr	-1546(ra) # 8000053c <panic>

0000000080003b4e <iunlock>:
{
    80003b4e:	1101                	add	sp,sp,-32
    80003b50:	ec06                	sd	ra,24(sp)
    80003b52:	e822                	sd	s0,16(sp)
    80003b54:	e426                	sd	s1,8(sp)
    80003b56:	e04a                	sd	s2,0(sp)
    80003b58:	1000                	add	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003b5a:	c905                	beqz	a0,80003b8a <iunlock+0x3c>
    80003b5c:	84aa                	mv	s1,a0
    80003b5e:	01050913          	add	s2,a0,16
    80003b62:	854a                	mv	a0,s2
    80003b64:	00001097          	auipc	ra,0x1
    80003b68:	c58080e7          	jalr	-936(ra) # 800047bc <holdingsleep>
    80003b6c:	cd19                	beqz	a0,80003b8a <iunlock+0x3c>
    80003b6e:	449c                	lw	a5,8(s1)
    80003b70:	00f05d63          	blez	a5,80003b8a <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003b74:	854a                	mv	a0,s2
    80003b76:	00001097          	auipc	ra,0x1
    80003b7a:	c02080e7          	jalr	-1022(ra) # 80004778 <releasesleep>
}
    80003b7e:	60e2                	ld	ra,24(sp)
    80003b80:	6442                	ld	s0,16(sp)
    80003b82:	64a2                	ld	s1,8(sp)
    80003b84:	6902                	ld	s2,0(sp)
    80003b86:	6105                	add	sp,sp,32
    80003b88:	8082                	ret
    panic("iunlock");
    80003b8a:	00005517          	auipc	a0,0x5
    80003b8e:	bd650513          	add	a0,a0,-1066 # 80008760 <syscalls+0x1b0>
    80003b92:	ffffd097          	auipc	ra,0xffffd
    80003b96:	9aa080e7          	jalr	-1622(ra) # 8000053c <panic>

0000000080003b9a <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003b9a:	7179                	add	sp,sp,-48
    80003b9c:	f406                	sd	ra,40(sp)
    80003b9e:	f022                	sd	s0,32(sp)
    80003ba0:	ec26                	sd	s1,24(sp)
    80003ba2:	e84a                	sd	s2,16(sp)
    80003ba4:	e44e                	sd	s3,8(sp)
    80003ba6:	e052                	sd	s4,0(sp)
    80003ba8:	1800                	add	s0,sp,48
    80003baa:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003bac:	05050493          	add	s1,a0,80
    80003bb0:	08050913          	add	s2,a0,128
    80003bb4:	a021                	j	80003bbc <itrunc+0x22>
    80003bb6:	0491                	add	s1,s1,4
    80003bb8:	01248d63          	beq	s1,s2,80003bd2 <itrunc+0x38>
    if(ip->addrs[i]){
    80003bbc:	408c                	lw	a1,0(s1)
    80003bbe:	dde5                	beqz	a1,80003bb6 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003bc0:	0009a503          	lw	a0,0(s3)
    80003bc4:	00000097          	auipc	ra,0x0
    80003bc8:	8fc080e7          	jalr	-1796(ra) # 800034c0 <bfree>
      ip->addrs[i] = 0;
    80003bcc:	0004a023          	sw	zero,0(s1)
    80003bd0:	b7dd                	j	80003bb6 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003bd2:	0809a583          	lw	a1,128(s3)
    80003bd6:	e185                	bnez	a1,80003bf6 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003bd8:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003bdc:	854e                	mv	a0,s3
    80003bde:	00000097          	auipc	ra,0x0
    80003be2:	de2080e7          	jalr	-542(ra) # 800039c0 <iupdate>
}
    80003be6:	70a2                	ld	ra,40(sp)
    80003be8:	7402                	ld	s0,32(sp)
    80003bea:	64e2                	ld	s1,24(sp)
    80003bec:	6942                	ld	s2,16(sp)
    80003bee:	69a2                	ld	s3,8(sp)
    80003bf0:	6a02                	ld	s4,0(sp)
    80003bf2:	6145                	add	sp,sp,48
    80003bf4:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003bf6:	0009a503          	lw	a0,0(s3)
    80003bfa:	fffff097          	auipc	ra,0xfffff
    80003bfe:	682080e7          	jalr	1666(ra) # 8000327c <bread>
    80003c02:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003c04:	05850493          	add	s1,a0,88
    80003c08:	45850913          	add	s2,a0,1112
    80003c0c:	a021                	j	80003c14 <itrunc+0x7a>
    80003c0e:	0491                	add	s1,s1,4
    80003c10:	01248b63          	beq	s1,s2,80003c26 <itrunc+0x8c>
      if(a[j])
    80003c14:	408c                	lw	a1,0(s1)
    80003c16:	dde5                	beqz	a1,80003c0e <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003c18:	0009a503          	lw	a0,0(s3)
    80003c1c:	00000097          	auipc	ra,0x0
    80003c20:	8a4080e7          	jalr	-1884(ra) # 800034c0 <bfree>
    80003c24:	b7ed                	j	80003c0e <itrunc+0x74>
    brelse(bp);
    80003c26:	8552                	mv	a0,s4
    80003c28:	fffff097          	auipc	ra,0xfffff
    80003c2c:	784080e7          	jalr	1924(ra) # 800033ac <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003c30:	0809a583          	lw	a1,128(s3)
    80003c34:	0009a503          	lw	a0,0(s3)
    80003c38:	00000097          	auipc	ra,0x0
    80003c3c:	888080e7          	jalr	-1912(ra) # 800034c0 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003c40:	0809a023          	sw	zero,128(s3)
    80003c44:	bf51                	j	80003bd8 <itrunc+0x3e>

0000000080003c46 <iput>:
{
    80003c46:	1101                	add	sp,sp,-32
    80003c48:	ec06                	sd	ra,24(sp)
    80003c4a:	e822                	sd	s0,16(sp)
    80003c4c:	e426                	sd	s1,8(sp)
    80003c4e:	e04a                	sd	s2,0(sp)
    80003c50:	1000                	add	s0,sp,32
    80003c52:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003c54:	0001c517          	auipc	a0,0x1c
    80003c58:	ea450513          	add	a0,a0,-348 # 8001faf8 <itable>
    80003c5c:	ffffd097          	auipc	ra,0xffffd
    80003c60:	f76080e7          	jalr	-138(ra) # 80000bd2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003c64:	4498                	lw	a4,8(s1)
    80003c66:	4785                	li	a5,1
    80003c68:	02f70363          	beq	a4,a5,80003c8e <iput+0x48>
  ip->ref--;
    80003c6c:	449c                	lw	a5,8(s1)
    80003c6e:	37fd                	addw	a5,a5,-1
    80003c70:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003c72:	0001c517          	auipc	a0,0x1c
    80003c76:	e8650513          	add	a0,a0,-378 # 8001faf8 <itable>
    80003c7a:	ffffd097          	auipc	ra,0xffffd
    80003c7e:	00c080e7          	jalr	12(ra) # 80000c86 <release>
}
    80003c82:	60e2                	ld	ra,24(sp)
    80003c84:	6442                	ld	s0,16(sp)
    80003c86:	64a2                	ld	s1,8(sp)
    80003c88:	6902                	ld	s2,0(sp)
    80003c8a:	6105                	add	sp,sp,32
    80003c8c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003c8e:	40bc                	lw	a5,64(s1)
    80003c90:	dff1                	beqz	a5,80003c6c <iput+0x26>
    80003c92:	04a49783          	lh	a5,74(s1)
    80003c96:	fbf9                	bnez	a5,80003c6c <iput+0x26>
    acquiresleep(&ip->lock);
    80003c98:	01048913          	add	s2,s1,16
    80003c9c:	854a                	mv	a0,s2
    80003c9e:	00001097          	auipc	ra,0x1
    80003ca2:	a84080e7          	jalr	-1404(ra) # 80004722 <acquiresleep>
    release(&itable.lock);
    80003ca6:	0001c517          	auipc	a0,0x1c
    80003caa:	e5250513          	add	a0,a0,-430 # 8001faf8 <itable>
    80003cae:	ffffd097          	auipc	ra,0xffffd
    80003cb2:	fd8080e7          	jalr	-40(ra) # 80000c86 <release>
    itrunc(ip);
    80003cb6:	8526                	mv	a0,s1
    80003cb8:	00000097          	auipc	ra,0x0
    80003cbc:	ee2080e7          	jalr	-286(ra) # 80003b9a <itrunc>
    ip->type = 0;
    80003cc0:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003cc4:	8526                	mv	a0,s1
    80003cc6:	00000097          	auipc	ra,0x0
    80003cca:	cfa080e7          	jalr	-774(ra) # 800039c0 <iupdate>
    ip->valid = 0;
    80003cce:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003cd2:	854a                	mv	a0,s2
    80003cd4:	00001097          	auipc	ra,0x1
    80003cd8:	aa4080e7          	jalr	-1372(ra) # 80004778 <releasesleep>
    acquire(&itable.lock);
    80003cdc:	0001c517          	auipc	a0,0x1c
    80003ce0:	e1c50513          	add	a0,a0,-484 # 8001faf8 <itable>
    80003ce4:	ffffd097          	auipc	ra,0xffffd
    80003ce8:	eee080e7          	jalr	-274(ra) # 80000bd2 <acquire>
    80003cec:	b741                	j	80003c6c <iput+0x26>

0000000080003cee <iunlockput>:
{
    80003cee:	1101                	add	sp,sp,-32
    80003cf0:	ec06                	sd	ra,24(sp)
    80003cf2:	e822                	sd	s0,16(sp)
    80003cf4:	e426                	sd	s1,8(sp)
    80003cf6:	1000                	add	s0,sp,32
    80003cf8:	84aa                	mv	s1,a0
  iunlock(ip);
    80003cfa:	00000097          	auipc	ra,0x0
    80003cfe:	e54080e7          	jalr	-428(ra) # 80003b4e <iunlock>
  iput(ip);
    80003d02:	8526                	mv	a0,s1
    80003d04:	00000097          	auipc	ra,0x0
    80003d08:	f42080e7          	jalr	-190(ra) # 80003c46 <iput>
}
    80003d0c:	60e2                	ld	ra,24(sp)
    80003d0e:	6442                	ld	s0,16(sp)
    80003d10:	64a2                	ld	s1,8(sp)
    80003d12:	6105                	add	sp,sp,32
    80003d14:	8082                	ret

0000000080003d16 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003d16:	1141                	add	sp,sp,-16
    80003d18:	e422                	sd	s0,8(sp)
    80003d1a:	0800                	add	s0,sp,16
  st->dev = ip->dev;
    80003d1c:	411c                	lw	a5,0(a0)
    80003d1e:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003d20:	415c                	lw	a5,4(a0)
    80003d22:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003d24:	04451783          	lh	a5,68(a0)
    80003d28:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003d2c:	04a51783          	lh	a5,74(a0)
    80003d30:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003d34:	04c56783          	lwu	a5,76(a0)
    80003d38:	e99c                	sd	a5,16(a1)
}
    80003d3a:	6422                	ld	s0,8(sp)
    80003d3c:	0141                	add	sp,sp,16
    80003d3e:	8082                	ret

0000000080003d40 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d40:	457c                	lw	a5,76(a0)
    80003d42:	0ed7e963          	bltu	a5,a3,80003e34 <readi+0xf4>
{
    80003d46:	7159                	add	sp,sp,-112
    80003d48:	f486                	sd	ra,104(sp)
    80003d4a:	f0a2                	sd	s0,96(sp)
    80003d4c:	eca6                	sd	s1,88(sp)
    80003d4e:	e8ca                	sd	s2,80(sp)
    80003d50:	e4ce                	sd	s3,72(sp)
    80003d52:	e0d2                	sd	s4,64(sp)
    80003d54:	fc56                	sd	s5,56(sp)
    80003d56:	f85a                	sd	s6,48(sp)
    80003d58:	f45e                	sd	s7,40(sp)
    80003d5a:	f062                	sd	s8,32(sp)
    80003d5c:	ec66                	sd	s9,24(sp)
    80003d5e:	e86a                	sd	s10,16(sp)
    80003d60:	e46e                	sd	s11,8(sp)
    80003d62:	1880                	add	s0,sp,112
    80003d64:	8b2a                	mv	s6,a0
    80003d66:	8bae                	mv	s7,a1
    80003d68:	8a32                	mv	s4,a2
    80003d6a:	84b6                	mv	s1,a3
    80003d6c:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003d6e:	9f35                	addw	a4,a4,a3
    return 0;
    80003d70:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003d72:	0ad76063          	bltu	a4,a3,80003e12 <readi+0xd2>
  if(off + n > ip->size)
    80003d76:	00e7f463          	bgeu	a5,a4,80003d7e <readi+0x3e>
    n = ip->size - off;
    80003d7a:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d7e:	0a0a8963          	beqz	s5,80003e30 <readi+0xf0>
    80003d82:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d84:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003d88:	5c7d                	li	s8,-1
    80003d8a:	a82d                	j	80003dc4 <readi+0x84>
    80003d8c:	020d1d93          	sll	s11,s10,0x20
    80003d90:	020ddd93          	srl	s11,s11,0x20
    80003d94:	05890613          	add	a2,s2,88
    80003d98:	86ee                	mv	a3,s11
    80003d9a:	963a                	add	a2,a2,a4
    80003d9c:	85d2                	mv	a1,s4
    80003d9e:	855e                	mv	a0,s7
    80003da0:	fffff097          	auipc	ra,0xfffff
    80003da4:	920080e7          	jalr	-1760(ra) # 800026c0 <either_copyout>
    80003da8:	05850d63          	beq	a0,s8,80003e02 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003dac:	854a                	mv	a0,s2
    80003dae:	fffff097          	auipc	ra,0xfffff
    80003db2:	5fe080e7          	jalr	1534(ra) # 800033ac <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003db6:	013d09bb          	addw	s3,s10,s3
    80003dba:	009d04bb          	addw	s1,s10,s1
    80003dbe:	9a6e                	add	s4,s4,s11
    80003dc0:	0559f763          	bgeu	s3,s5,80003e0e <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003dc4:	00a4d59b          	srlw	a1,s1,0xa
    80003dc8:	855a                	mv	a0,s6
    80003dca:	00000097          	auipc	ra,0x0
    80003dce:	8a4080e7          	jalr	-1884(ra) # 8000366e <bmap>
    80003dd2:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003dd6:	cd85                	beqz	a1,80003e0e <readi+0xce>
    bp = bread(ip->dev, addr);
    80003dd8:	000b2503          	lw	a0,0(s6)
    80003ddc:	fffff097          	auipc	ra,0xfffff
    80003de0:	4a0080e7          	jalr	1184(ra) # 8000327c <bread>
    80003de4:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003de6:	3ff4f713          	and	a4,s1,1023
    80003dea:	40ec87bb          	subw	a5,s9,a4
    80003dee:	413a86bb          	subw	a3,s5,s3
    80003df2:	8d3e                	mv	s10,a5
    80003df4:	2781                	sext.w	a5,a5
    80003df6:	0006861b          	sext.w	a2,a3
    80003dfa:	f8f679e3          	bgeu	a2,a5,80003d8c <readi+0x4c>
    80003dfe:	8d36                	mv	s10,a3
    80003e00:	b771                	j	80003d8c <readi+0x4c>
      brelse(bp);
    80003e02:	854a                	mv	a0,s2
    80003e04:	fffff097          	auipc	ra,0xfffff
    80003e08:	5a8080e7          	jalr	1448(ra) # 800033ac <brelse>
      tot = -1;
    80003e0c:	59fd                	li	s3,-1
  }
  return tot;
    80003e0e:	0009851b          	sext.w	a0,s3
}
    80003e12:	70a6                	ld	ra,104(sp)
    80003e14:	7406                	ld	s0,96(sp)
    80003e16:	64e6                	ld	s1,88(sp)
    80003e18:	6946                	ld	s2,80(sp)
    80003e1a:	69a6                	ld	s3,72(sp)
    80003e1c:	6a06                	ld	s4,64(sp)
    80003e1e:	7ae2                	ld	s5,56(sp)
    80003e20:	7b42                	ld	s6,48(sp)
    80003e22:	7ba2                	ld	s7,40(sp)
    80003e24:	7c02                	ld	s8,32(sp)
    80003e26:	6ce2                	ld	s9,24(sp)
    80003e28:	6d42                	ld	s10,16(sp)
    80003e2a:	6da2                	ld	s11,8(sp)
    80003e2c:	6165                	add	sp,sp,112
    80003e2e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e30:	89d6                	mv	s3,s5
    80003e32:	bff1                	j	80003e0e <readi+0xce>
    return 0;
    80003e34:	4501                	li	a0,0
}
    80003e36:	8082                	ret

0000000080003e38 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003e38:	457c                	lw	a5,76(a0)
    80003e3a:	10d7e863          	bltu	a5,a3,80003f4a <writei+0x112>
{
    80003e3e:	7159                	add	sp,sp,-112
    80003e40:	f486                	sd	ra,104(sp)
    80003e42:	f0a2                	sd	s0,96(sp)
    80003e44:	eca6                	sd	s1,88(sp)
    80003e46:	e8ca                	sd	s2,80(sp)
    80003e48:	e4ce                	sd	s3,72(sp)
    80003e4a:	e0d2                	sd	s4,64(sp)
    80003e4c:	fc56                	sd	s5,56(sp)
    80003e4e:	f85a                	sd	s6,48(sp)
    80003e50:	f45e                	sd	s7,40(sp)
    80003e52:	f062                	sd	s8,32(sp)
    80003e54:	ec66                	sd	s9,24(sp)
    80003e56:	e86a                	sd	s10,16(sp)
    80003e58:	e46e                	sd	s11,8(sp)
    80003e5a:	1880                	add	s0,sp,112
    80003e5c:	8aaa                	mv	s5,a0
    80003e5e:	8bae                	mv	s7,a1
    80003e60:	8a32                	mv	s4,a2
    80003e62:	8936                	mv	s2,a3
    80003e64:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003e66:	00e687bb          	addw	a5,a3,a4
    80003e6a:	0ed7e263          	bltu	a5,a3,80003f4e <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003e6e:	00043737          	lui	a4,0x43
    80003e72:	0ef76063          	bltu	a4,a5,80003f52 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e76:	0c0b0863          	beqz	s6,80003f46 <writei+0x10e>
    80003e7a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e7c:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003e80:	5c7d                	li	s8,-1
    80003e82:	a091                	j	80003ec6 <writei+0x8e>
    80003e84:	020d1d93          	sll	s11,s10,0x20
    80003e88:	020ddd93          	srl	s11,s11,0x20
    80003e8c:	05848513          	add	a0,s1,88
    80003e90:	86ee                	mv	a3,s11
    80003e92:	8652                	mv	a2,s4
    80003e94:	85de                	mv	a1,s7
    80003e96:	953a                	add	a0,a0,a4
    80003e98:	fffff097          	auipc	ra,0xfffff
    80003e9c:	87e080e7          	jalr	-1922(ra) # 80002716 <either_copyin>
    80003ea0:	07850263          	beq	a0,s8,80003f04 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003ea4:	8526                	mv	a0,s1
    80003ea6:	00000097          	auipc	ra,0x0
    80003eaa:	75e080e7          	jalr	1886(ra) # 80004604 <log_write>
    brelse(bp);
    80003eae:	8526                	mv	a0,s1
    80003eb0:	fffff097          	auipc	ra,0xfffff
    80003eb4:	4fc080e7          	jalr	1276(ra) # 800033ac <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003eb8:	013d09bb          	addw	s3,s10,s3
    80003ebc:	012d093b          	addw	s2,s10,s2
    80003ec0:	9a6e                	add	s4,s4,s11
    80003ec2:	0569f663          	bgeu	s3,s6,80003f0e <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003ec6:	00a9559b          	srlw	a1,s2,0xa
    80003eca:	8556                	mv	a0,s5
    80003ecc:	fffff097          	auipc	ra,0xfffff
    80003ed0:	7a2080e7          	jalr	1954(ra) # 8000366e <bmap>
    80003ed4:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003ed8:	c99d                	beqz	a1,80003f0e <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003eda:	000aa503          	lw	a0,0(s5)
    80003ede:	fffff097          	auipc	ra,0xfffff
    80003ee2:	39e080e7          	jalr	926(ra) # 8000327c <bread>
    80003ee6:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ee8:	3ff97713          	and	a4,s2,1023
    80003eec:	40ec87bb          	subw	a5,s9,a4
    80003ef0:	413b06bb          	subw	a3,s6,s3
    80003ef4:	8d3e                	mv	s10,a5
    80003ef6:	2781                	sext.w	a5,a5
    80003ef8:	0006861b          	sext.w	a2,a3
    80003efc:	f8f674e3          	bgeu	a2,a5,80003e84 <writei+0x4c>
    80003f00:	8d36                	mv	s10,a3
    80003f02:	b749                	j	80003e84 <writei+0x4c>
      brelse(bp);
    80003f04:	8526                	mv	a0,s1
    80003f06:	fffff097          	auipc	ra,0xfffff
    80003f0a:	4a6080e7          	jalr	1190(ra) # 800033ac <brelse>
  }

  if(off > ip->size)
    80003f0e:	04caa783          	lw	a5,76(s5)
    80003f12:	0127f463          	bgeu	a5,s2,80003f1a <writei+0xe2>
    ip->size = off;
    80003f16:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003f1a:	8556                	mv	a0,s5
    80003f1c:	00000097          	auipc	ra,0x0
    80003f20:	aa4080e7          	jalr	-1372(ra) # 800039c0 <iupdate>

  return tot;
    80003f24:	0009851b          	sext.w	a0,s3
}
    80003f28:	70a6                	ld	ra,104(sp)
    80003f2a:	7406                	ld	s0,96(sp)
    80003f2c:	64e6                	ld	s1,88(sp)
    80003f2e:	6946                	ld	s2,80(sp)
    80003f30:	69a6                	ld	s3,72(sp)
    80003f32:	6a06                	ld	s4,64(sp)
    80003f34:	7ae2                	ld	s5,56(sp)
    80003f36:	7b42                	ld	s6,48(sp)
    80003f38:	7ba2                	ld	s7,40(sp)
    80003f3a:	7c02                	ld	s8,32(sp)
    80003f3c:	6ce2                	ld	s9,24(sp)
    80003f3e:	6d42                	ld	s10,16(sp)
    80003f40:	6da2                	ld	s11,8(sp)
    80003f42:	6165                	add	sp,sp,112
    80003f44:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f46:	89da                	mv	s3,s6
    80003f48:	bfc9                	j	80003f1a <writei+0xe2>
    return -1;
    80003f4a:	557d                	li	a0,-1
}
    80003f4c:	8082                	ret
    return -1;
    80003f4e:	557d                	li	a0,-1
    80003f50:	bfe1                	j	80003f28 <writei+0xf0>
    return -1;
    80003f52:	557d                	li	a0,-1
    80003f54:	bfd1                	j	80003f28 <writei+0xf0>

0000000080003f56 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003f56:	1141                	add	sp,sp,-16
    80003f58:	e406                	sd	ra,8(sp)
    80003f5a:	e022                	sd	s0,0(sp)
    80003f5c:	0800                	add	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003f5e:	4639                	li	a2,14
    80003f60:	ffffd097          	auipc	ra,0xffffd
    80003f64:	e3e080e7          	jalr	-450(ra) # 80000d9e <strncmp>
}
    80003f68:	60a2                	ld	ra,8(sp)
    80003f6a:	6402                	ld	s0,0(sp)
    80003f6c:	0141                	add	sp,sp,16
    80003f6e:	8082                	ret

0000000080003f70 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003f70:	7139                	add	sp,sp,-64
    80003f72:	fc06                	sd	ra,56(sp)
    80003f74:	f822                	sd	s0,48(sp)
    80003f76:	f426                	sd	s1,40(sp)
    80003f78:	f04a                	sd	s2,32(sp)
    80003f7a:	ec4e                	sd	s3,24(sp)
    80003f7c:	e852                	sd	s4,16(sp)
    80003f7e:	0080                	add	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003f80:	04451703          	lh	a4,68(a0)
    80003f84:	4785                	li	a5,1
    80003f86:	00f71a63          	bne	a4,a5,80003f9a <dirlookup+0x2a>
    80003f8a:	892a                	mv	s2,a0
    80003f8c:	89ae                	mv	s3,a1
    80003f8e:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f90:	457c                	lw	a5,76(a0)
    80003f92:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003f94:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f96:	e79d                	bnez	a5,80003fc4 <dirlookup+0x54>
    80003f98:	a8a5                	j	80004010 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003f9a:	00004517          	auipc	a0,0x4
    80003f9e:	7ce50513          	add	a0,a0,1998 # 80008768 <syscalls+0x1b8>
    80003fa2:	ffffc097          	auipc	ra,0xffffc
    80003fa6:	59a080e7          	jalr	1434(ra) # 8000053c <panic>
      panic("dirlookup read");
    80003faa:	00004517          	auipc	a0,0x4
    80003fae:	7d650513          	add	a0,a0,2006 # 80008780 <syscalls+0x1d0>
    80003fb2:	ffffc097          	auipc	ra,0xffffc
    80003fb6:	58a080e7          	jalr	1418(ra) # 8000053c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fba:	24c1                	addw	s1,s1,16
    80003fbc:	04c92783          	lw	a5,76(s2)
    80003fc0:	04f4f763          	bgeu	s1,a5,8000400e <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fc4:	4741                	li	a4,16
    80003fc6:	86a6                	mv	a3,s1
    80003fc8:	fc040613          	add	a2,s0,-64
    80003fcc:	4581                	li	a1,0
    80003fce:	854a                	mv	a0,s2
    80003fd0:	00000097          	auipc	ra,0x0
    80003fd4:	d70080e7          	jalr	-656(ra) # 80003d40 <readi>
    80003fd8:	47c1                	li	a5,16
    80003fda:	fcf518e3          	bne	a0,a5,80003faa <dirlookup+0x3a>
    if(de.inum == 0)
    80003fde:	fc045783          	lhu	a5,-64(s0)
    80003fe2:	dfe1                	beqz	a5,80003fba <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003fe4:	fc240593          	add	a1,s0,-62
    80003fe8:	854e                	mv	a0,s3
    80003fea:	00000097          	auipc	ra,0x0
    80003fee:	f6c080e7          	jalr	-148(ra) # 80003f56 <namecmp>
    80003ff2:	f561                	bnez	a0,80003fba <dirlookup+0x4a>
      if(poff)
    80003ff4:	000a0463          	beqz	s4,80003ffc <dirlookup+0x8c>
        *poff = off;
    80003ff8:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003ffc:	fc045583          	lhu	a1,-64(s0)
    80004000:	00092503          	lw	a0,0(s2)
    80004004:	fffff097          	auipc	ra,0xfffff
    80004008:	754080e7          	jalr	1876(ra) # 80003758 <iget>
    8000400c:	a011                	j	80004010 <dirlookup+0xa0>
  return 0;
    8000400e:	4501                	li	a0,0
}
    80004010:	70e2                	ld	ra,56(sp)
    80004012:	7442                	ld	s0,48(sp)
    80004014:	74a2                	ld	s1,40(sp)
    80004016:	7902                	ld	s2,32(sp)
    80004018:	69e2                	ld	s3,24(sp)
    8000401a:	6a42                	ld	s4,16(sp)
    8000401c:	6121                	add	sp,sp,64
    8000401e:	8082                	ret

0000000080004020 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004020:	711d                	add	sp,sp,-96
    80004022:	ec86                	sd	ra,88(sp)
    80004024:	e8a2                	sd	s0,80(sp)
    80004026:	e4a6                	sd	s1,72(sp)
    80004028:	e0ca                	sd	s2,64(sp)
    8000402a:	fc4e                	sd	s3,56(sp)
    8000402c:	f852                	sd	s4,48(sp)
    8000402e:	f456                	sd	s5,40(sp)
    80004030:	f05a                	sd	s6,32(sp)
    80004032:	ec5e                	sd	s7,24(sp)
    80004034:	e862                	sd	s8,16(sp)
    80004036:	e466                	sd	s9,8(sp)
    80004038:	1080                	add	s0,sp,96
    8000403a:	84aa                	mv	s1,a0
    8000403c:	8b2e                	mv	s6,a1
    8000403e:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004040:	00054703          	lbu	a4,0(a0)
    80004044:	02f00793          	li	a5,47
    80004048:	02f70263          	beq	a4,a5,8000406c <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000404c:	ffffe097          	auipc	ra,0xffffe
    80004050:	95a080e7          	jalr	-1702(ra) # 800019a6 <myproc>
    80004054:	15053503          	ld	a0,336(a0)
    80004058:	00000097          	auipc	ra,0x0
    8000405c:	9f6080e7          	jalr	-1546(ra) # 80003a4e <idup>
    80004060:	8a2a                	mv	s4,a0
  while(*path == '/')
    80004062:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80004066:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004068:	4b85                	li	s7,1
    8000406a:	a875                	j	80004126 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    8000406c:	4585                	li	a1,1
    8000406e:	4505                	li	a0,1
    80004070:	fffff097          	auipc	ra,0xfffff
    80004074:	6e8080e7          	jalr	1768(ra) # 80003758 <iget>
    80004078:	8a2a                	mv	s4,a0
    8000407a:	b7e5                	j	80004062 <namex+0x42>
      iunlockput(ip);
    8000407c:	8552                	mv	a0,s4
    8000407e:	00000097          	auipc	ra,0x0
    80004082:	c70080e7          	jalr	-912(ra) # 80003cee <iunlockput>
      return 0;
    80004086:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004088:	8552                	mv	a0,s4
    8000408a:	60e6                	ld	ra,88(sp)
    8000408c:	6446                	ld	s0,80(sp)
    8000408e:	64a6                	ld	s1,72(sp)
    80004090:	6906                	ld	s2,64(sp)
    80004092:	79e2                	ld	s3,56(sp)
    80004094:	7a42                	ld	s4,48(sp)
    80004096:	7aa2                	ld	s5,40(sp)
    80004098:	7b02                	ld	s6,32(sp)
    8000409a:	6be2                	ld	s7,24(sp)
    8000409c:	6c42                	ld	s8,16(sp)
    8000409e:	6ca2                	ld	s9,8(sp)
    800040a0:	6125                	add	sp,sp,96
    800040a2:	8082                	ret
      iunlock(ip);
    800040a4:	8552                	mv	a0,s4
    800040a6:	00000097          	auipc	ra,0x0
    800040aa:	aa8080e7          	jalr	-1368(ra) # 80003b4e <iunlock>
      return ip;
    800040ae:	bfe9                	j	80004088 <namex+0x68>
      iunlockput(ip);
    800040b0:	8552                	mv	a0,s4
    800040b2:	00000097          	auipc	ra,0x0
    800040b6:	c3c080e7          	jalr	-964(ra) # 80003cee <iunlockput>
      return 0;
    800040ba:	8a4e                	mv	s4,s3
    800040bc:	b7f1                	j	80004088 <namex+0x68>
  len = path - s;
    800040be:	40998633          	sub	a2,s3,s1
    800040c2:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800040c6:	099c5863          	bge	s8,s9,80004156 <namex+0x136>
    memmove(name, s, DIRSIZ);
    800040ca:	4639                	li	a2,14
    800040cc:	85a6                	mv	a1,s1
    800040ce:	8556                	mv	a0,s5
    800040d0:	ffffd097          	auipc	ra,0xffffd
    800040d4:	c5a080e7          	jalr	-934(ra) # 80000d2a <memmove>
    800040d8:	84ce                	mv	s1,s3
  while(*path == '/')
    800040da:	0004c783          	lbu	a5,0(s1)
    800040de:	01279763          	bne	a5,s2,800040ec <namex+0xcc>
    path++;
    800040e2:	0485                	add	s1,s1,1
  while(*path == '/')
    800040e4:	0004c783          	lbu	a5,0(s1)
    800040e8:	ff278de3          	beq	a5,s2,800040e2 <namex+0xc2>
    ilock(ip);
    800040ec:	8552                	mv	a0,s4
    800040ee:	00000097          	auipc	ra,0x0
    800040f2:	99e080e7          	jalr	-1634(ra) # 80003a8c <ilock>
    if(ip->type != T_DIR){
    800040f6:	044a1783          	lh	a5,68(s4)
    800040fa:	f97791e3          	bne	a5,s7,8000407c <namex+0x5c>
    if(nameiparent && *path == '\0'){
    800040fe:	000b0563          	beqz	s6,80004108 <namex+0xe8>
    80004102:	0004c783          	lbu	a5,0(s1)
    80004106:	dfd9                	beqz	a5,800040a4 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004108:	4601                	li	a2,0
    8000410a:	85d6                	mv	a1,s5
    8000410c:	8552                	mv	a0,s4
    8000410e:	00000097          	auipc	ra,0x0
    80004112:	e62080e7          	jalr	-414(ra) # 80003f70 <dirlookup>
    80004116:	89aa                	mv	s3,a0
    80004118:	dd41                	beqz	a0,800040b0 <namex+0x90>
    iunlockput(ip);
    8000411a:	8552                	mv	a0,s4
    8000411c:	00000097          	auipc	ra,0x0
    80004120:	bd2080e7          	jalr	-1070(ra) # 80003cee <iunlockput>
    ip = next;
    80004124:	8a4e                	mv	s4,s3
  while(*path == '/')
    80004126:	0004c783          	lbu	a5,0(s1)
    8000412a:	01279763          	bne	a5,s2,80004138 <namex+0x118>
    path++;
    8000412e:	0485                	add	s1,s1,1
  while(*path == '/')
    80004130:	0004c783          	lbu	a5,0(s1)
    80004134:	ff278de3          	beq	a5,s2,8000412e <namex+0x10e>
  if(*path == 0)
    80004138:	cb9d                	beqz	a5,8000416e <namex+0x14e>
  while(*path != '/' && *path != 0)
    8000413a:	0004c783          	lbu	a5,0(s1)
    8000413e:	89a6                	mv	s3,s1
  len = path - s;
    80004140:	4c81                	li	s9,0
    80004142:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80004144:	01278963          	beq	a5,s2,80004156 <namex+0x136>
    80004148:	dbbd                	beqz	a5,800040be <namex+0x9e>
    path++;
    8000414a:	0985                	add	s3,s3,1
  while(*path != '/' && *path != 0)
    8000414c:	0009c783          	lbu	a5,0(s3)
    80004150:	ff279ce3          	bne	a5,s2,80004148 <namex+0x128>
    80004154:	b7ad                	j	800040be <namex+0x9e>
    memmove(name, s, len);
    80004156:	2601                	sext.w	a2,a2
    80004158:	85a6                	mv	a1,s1
    8000415a:	8556                	mv	a0,s5
    8000415c:	ffffd097          	auipc	ra,0xffffd
    80004160:	bce080e7          	jalr	-1074(ra) # 80000d2a <memmove>
    name[len] = 0;
    80004164:	9cd6                	add	s9,s9,s5
    80004166:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000416a:	84ce                	mv	s1,s3
    8000416c:	b7bd                	j	800040da <namex+0xba>
  if(nameiparent){
    8000416e:	f00b0de3          	beqz	s6,80004088 <namex+0x68>
    iput(ip);
    80004172:	8552                	mv	a0,s4
    80004174:	00000097          	auipc	ra,0x0
    80004178:	ad2080e7          	jalr	-1326(ra) # 80003c46 <iput>
    return 0;
    8000417c:	4a01                	li	s4,0
    8000417e:	b729                	j	80004088 <namex+0x68>

0000000080004180 <dirlink>:
{
    80004180:	7139                	add	sp,sp,-64
    80004182:	fc06                	sd	ra,56(sp)
    80004184:	f822                	sd	s0,48(sp)
    80004186:	f426                	sd	s1,40(sp)
    80004188:	f04a                	sd	s2,32(sp)
    8000418a:	ec4e                	sd	s3,24(sp)
    8000418c:	e852                	sd	s4,16(sp)
    8000418e:	0080                	add	s0,sp,64
    80004190:	892a                	mv	s2,a0
    80004192:	8a2e                	mv	s4,a1
    80004194:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004196:	4601                	li	a2,0
    80004198:	00000097          	auipc	ra,0x0
    8000419c:	dd8080e7          	jalr	-552(ra) # 80003f70 <dirlookup>
    800041a0:	e93d                	bnez	a0,80004216 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041a2:	04c92483          	lw	s1,76(s2)
    800041a6:	c49d                	beqz	s1,800041d4 <dirlink+0x54>
    800041a8:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041aa:	4741                	li	a4,16
    800041ac:	86a6                	mv	a3,s1
    800041ae:	fc040613          	add	a2,s0,-64
    800041b2:	4581                	li	a1,0
    800041b4:	854a                	mv	a0,s2
    800041b6:	00000097          	auipc	ra,0x0
    800041ba:	b8a080e7          	jalr	-1142(ra) # 80003d40 <readi>
    800041be:	47c1                	li	a5,16
    800041c0:	06f51163          	bne	a0,a5,80004222 <dirlink+0xa2>
    if(de.inum == 0)
    800041c4:	fc045783          	lhu	a5,-64(s0)
    800041c8:	c791                	beqz	a5,800041d4 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041ca:	24c1                	addw	s1,s1,16
    800041cc:	04c92783          	lw	a5,76(s2)
    800041d0:	fcf4ede3          	bltu	s1,a5,800041aa <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800041d4:	4639                	li	a2,14
    800041d6:	85d2                	mv	a1,s4
    800041d8:	fc240513          	add	a0,s0,-62
    800041dc:	ffffd097          	auipc	ra,0xffffd
    800041e0:	bfe080e7          	jalr	-1026(ra) # 80000dda <strncpy>
  de.inum = inum;
    800041e4:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041e8:	4741                	li	a4,16
    800041ea:	86a6                	mv	a3,s1
    800041ec:	fc040613          	add	a2,s0,-64
    800041f0:	4581                	li	a1,0
    800041f2:	854a                	mv	a0,s2
    800041f4:	00000097          	auipc	ra,0x0
    800041f8:	c44080e7          	jalr	-956(ra) # 80003e38 <writei>
    800041fc:	1541                	add	a0,a0,-16
    800041fe:	00a03533          	snez	a0,a0
    80004202:	40a00533          	neg	a0,a0
}
    80004206:	70e2                	ld	ra,56(sp)
    80004208:	7442                	ld	s0,48(sp)
    8000420a:	74a2                	ld	s1,40(sp)
    8000420c:	7902                	ld	s2,32(sp)
    8000420e:	69e2                	ld	s3,24(sp)
    80004210:	6a42                	ld	s4,16(sp)
    80004212:	6121                	add	sp,sp,64
    80004214:	8082                	ret
    iput(ip);
    80004216:	00000097          	auipc	ra,0x0
    8000421a:	a30080e7          	jalr	-1488(ra) # 80003c46 <iput>
    return -1;
    8000421e:	557d                	li	a0,-1
    80004220:	b7dd                	j	80004206 <dirlink+0x86>
      panic("dirlink read");
    80004222:	00004517          	auipc	a0,0x4
    80004226:	56e50513          	add	a0,a0,1390 # 80008790 <syscalls+0x1e0>
    8000422a:	ffffc097          	auipc	ra,0xffffc
    8000422e:	312080e7          	jalr	786(ra) # 8000053c <panic>

0000000080004232 <namei>:

struct inode*
namei(char *path)
{
    80004232:	1101                	add	sp,sp,-32
    80004234:	ec06                	sd	ra,24(sp)
    80004236:	e822                	sd	s0,16(sp)
    80004238:	1000                	add	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000423a:	fe040613          	add	a2,s0,-32
    8000423e:	4581                	li	a1,0
    80004240:	00000097          	auipc	ra,0x0
    80004244:	de0080e7          	jalr	-544(ra) # 80004020 <namex>
}
    80004248:	60e2                	ld	ra,24(sp)
    8000424a:	6442                	ld	s0,16(sp)
    8000424c:	6105                	add	sp,sp,32
    8000424e:	8082                	ret

0000000080004250 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004250:	1141                	add	sp,sp,-16
    80004252:	e406                	sd	ra,8(sp)
    80004254:	e022                	sd	s0,0(sp)
    80004256:	0800                	add	s0,sp,16
    80004258:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000425a:	4585                	li	a1,1
    8000425c:	00000097          	auipc	ra,0x0
    80004260:	dc4080e7          	jalr	-572(ra) # 80004020 <namex>
}
    80004264:	60a2                	ld	ra,8(sp)
    80004266:	6402                	ld	s0,0(sp)
    80004268:	0141                	add	sp,sp,16
    8000426a:	8082                	ret

000000008000426c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000426c:	1101                	add	sp,sp,-32
    8000426e:	ec06                	sd	ra,24(sp)
    80004270:	e822                	sd	s0,16(sp)
    80004272:	e426                	sd	s1,8(sp)
    80004274:	e04a                	sd	s2,0(sp)
    80004276:	1000                	add	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004278:	0001d917          	auipc	s2,0x1d
    8000427c:	32890913          	add	s2,s2,808 # 800215a0 <log>
    80004280:	01892583          	lw	a1,24(s2)
    80004284:	02892503          	lw	a0,40(s2)
    80004288:	fffff097          	auipc	ra,0xfffff
    8000428c:	ff4080e7          	jalr	-12(ra) # 8000327c <bread>
    80004290:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004292:	02c92603          	lw	a2,44(s2)
    80004296:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004298:	00c05f63          	blez	a2,800042b6 <write_head+0x4a>
    8000429c:	0001d717          	auipc	a4,0x1d
    800042a0:	33470713          	add	a4,a4,820 # 800215d0 <log+0x30>
    800042a4:	87aa                	mv	a5,a0
    800042a6:	060a                	sll	a2,a2,0x2
    800042a8:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    800042aa:	4314                	lw	a3,0(a4)
    800042ac:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    800042ae:	0711                	add	a4,a4,4
    800042b0:	0791                	add	a5,a5,4
    800042b2:	fec79ce3          	bne	a5,a2,800042aa <write_head+0x3e>
  }
  bwrite(buf);
    800042b6:	8526                	mv	a0,s1
    800042b8:	fffff097          	auipc	ra,0xfffff
    800042bc:	0b6080e7          	jalr	182(ra) # 8000336e <bwrite>
  brelse(buf);
    800042c0:	8526                	mv	a0,s1
    800042c2:	fffff097          	auipc	ra,0xfffff
    800042c6:	0ea080e7          	jalr	234(ra) # 800033ac <brelse>
}
    800042ca:	60e2                	ld	ra,24(sp)
    800042cc:	6442                	ld	s0,16(sp)
    800042ce:	64a2                	ld	s1,8(sp)
    800042d0:	6902                	ld	s2,0(sp)
    800042d2:	6105                	add	sp,sp,32
    800042d4:	8082                	ret

00000000800042d6 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800042d6:	0001d797          	auipc	a5,0x1d
    800042da:	2f67a783          	lw	a5,758(a5) # 800215cc <log+0x2c>
    800042de:	0af05d63          	blez	a5,80004398 <install_trans+0xc2>
{
    800042e2:	7139                	add	sp,sp,-64
    800042e4:	fc06                	sd	ra,56(sp)
    800042e6:	f822                	sd	s0,48(sp)
    800042e8:	f426                	sd	s1,40(sp)
    800042ea:	f04a                	sd	s2,32(sp)
    800042ec:	ec4e                	sd	s3,24(sp)
    800042ee:	e852                	sd	s4,16(sp)
    800042f0:	e456                	sd	s5,8(sp)
    800042f2:	e05a                	sd	s6,0(sp)
    800042f4:	0080                	add	s0,sp,64
    800042f6:	8b2a                	mv	s6,a0
    800042f8:	0001da97          	auipc	s5,0x1d
    800042fc:	2d8a8a93          	add	s5,s5,728 # 800215d0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004300:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004302:	0001d997          	auipc	s3,0x1d
    80004306:	29e98993          	add	s3,s3,670 # 800215a0 <log>
    8000430a:	a00d                	j	8000432c <install_trans+0x56>
    brelse(lbuf);
    8000430c:	854a                	mv	a0,s2
    8000430e:	fffff097          	auipc	ra,0xfffff
    80004312:	09e080e7          	jalr	158(ra) # 800033ac <brelse>
    brelse(dbuf);
    80004316:	8526                	mv	a0,s1
    80004318:	fffff097          	auipc	ra,0xfffff
    8000431c:	094080e7          	jalr	148(ra) # 800033ac <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004320:	2a05                	addw	s4,s4,1
    80004322:	0a91                	add	s5,s5,4
    80004324:	02c9a783          	lw	a5,44(s3)
    80004328:	04fa5e63          	bge	s4,a5,80004384 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000432c:	0189a583          	lw	a1,24(s3)
    80004330:	014585bb          	addw	a1,a1,s4
    80004334:	2585                	addw	a1,a1,1
    80004336:	0289a503          	lw	a0,40(s3)
    8000433a:	fffff097          	auipc	ra,0xfffff
    8000433e:	f42080e7          	jalr	-190(ra) # 8000327c <bread>
    80004342:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004344:	000aa583          	lw	a1,0(s5)
    80004348:	0289a503          	lw	a0,40(s3)
    8000434c:	fffff097          	auipc	ra,0xfffff
    80004350:	f30080e7          	jalr	-208(ra) # 8000327c <bread>
    80004354:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004356:	40000613          	li	a2,1024
    8000435a:	05890593          	add	a1,s2,88
    8000435e:	05850513          	add	a0,a0,88
    80004362:	ffffd097          	auipc	ra,0xffffd
    80004366:	9c8080e7          	jalr	-1592(ra) # 80000d2a <memmove>
    bwrite(dbuf);  // write dst to disk
    8000436a:	8526                	mv	a0,s1
    8000436c:	fffff097          	auipc	ra,0xfffff
    80004370:	002080e7          	jalr	2(ra) # 8000336e <bwrite>
    if(recovering == 0)
    80004374:	f80b1ce3          	bnez	s6,8000430c <install_trans+0x36>
      bunpin(dbuf);
    80004378:	8526                	mv	a0,s1
    8000437a:	fffff097          	auipc	ra,0xfffff
    8000437e:	10a080e7          	jalr	266(ra) # 80003484 <bunpin>
    80004382:	b769                	j	8000430c <install_trans+0x36>
}
    80004384:	70e2                	ld	ra,56(sp)
    80004386:	7442                	ld	s0,48(sp)
    80004388:	74a2                	ld	s1,40(sp)
    8000438a:	7902                	ld	s2,32(sp)
    8000438c:	69e2                	ld	s3,24(sp)
    8000438e:	6a42                	ld	s4,16(sp)
    80004390:	6aa2                	ld	s5,8(sp)
    80004392:	6b02                	ld	s6,0(sp)
    80004394:	6121                	add	sp,sp,64
    80004396:	8082                	ret
    80004398:	8082                	ret

000000008000439a <initlog>:
{
    8000439a:	7179                	add	sp,sp,-48
    8000439c:	f406                	sd	ra,40(sp)
    8000439e:	f022                	sd	s0,32(sp)
    800043a0:	ec26                	sd	s1,24(sp)
    800043a2:	e84a                	sd	s2,16(sp)
    800043a4:	e44e                	sd	s3,8(sp)
    800043a6:	1800                	add	s0,sp,48
    800043a8:	892a                	mv	s2,a0
    800043aa:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800043ac:	0001d497          	auipc	s1,0x1d
    800043b0:	1f448493          	add	s1,s1,500 # 800215a0 <log>
    800043b4:	00004597          	auipc	a1,0x4
    800043b8:	3ec58593          	add	a1,a1,1004 # 800087a0 <syscalls+0x1f0>
    800043bc:	8526                	mv	a0,s1
    800043be:	ffffc097          	auipc	ra,0xffffc
    800043c2:	784080e7          	jalr	1924(ra) # 80000b42 <initlock>
  log.start = sb->logstart;
    800043c6:	0149a583          	lw	a1,20(s3)
    800043ca:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800043cc:	0109a783          	lw	a5,16(s3)
    800043d0:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800043d2:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800043d6:	854a                	mv	a0,s2
    800043d8:	fffff097          	auipc	ra,0xfffff
    800043dc:	ea4080e7          	jalr	-348(ra) # 8000327c <bread>
  log.lh.n = lh->n;
    800043e0:	4d30                	lw	a2,88(a0)
    800043e2:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800043e4:	00c05f63          	blez	a2,80004402 <initlog+0x68>
    800043e8:	87aa                	mv	a5,a0
    800043ea:	0001d717          	auipc	a4,0x1d
    800043ee:	1e670713          	add	a4,a4,486 # 800215d0 <log+0x30>
    800043f2:	060a                	sll	a2,a2,0x2
    800043f4:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    800043f6:	4ff4                	lw	a3,92(a5)
    800043f8:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800043fa:	0791                	add	a5,a5,4
    800043fc:	0711                	add	a4,a4,4
    800043fe:	fec79ce3          	bne	a5,a2,800043f6 <initlog+0x5c>
  brelse(buf);
    80004402:	fffff097          	auipc	ra,0xfffff
    80004406:	faa080e7          	jalr	-86(ra) # 800033ac <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000440a:	4505                	li	a0,1
    8000440c:	00000097          	auipc	ra,0x0
    80004410:	eca080e7          	jalr	-310(ra) # 800042d6 <install_trans>
  log.lh.n = 0;
    80004414:	0001d797          	auipc	a5,0x1d
    80004418:	1a07ac23          	sw	zero,440(a5) # 800215cc <log+0x2c>
  write_head(); // clear the log
    8000441c:	00000097          	auipc	ra,0x0
    80004420:	e50080e7          	jalr	-432(ra) # 8000426c <write_head>
}
    80004424:	70a2                	ld	ra,40(sp)
    80004426:	7402                	ld	s0,32(sp)
    80004428:	64e2                	ld	s1,24(sp)
    8000442a:	6942                	ld	s2,16(sp)
    8000442c:	69a2                	ld	s3,8(sp)
    8000442e:	6145                	add	sp,sp,48
    80004430:	8082                	ret

0000000080004432 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004432:	1101                	add	sp,sp,-32
    80004434:	ec06                	sd	ra,24(sp)
    80004436:	e822                	sd	s0,16(sp)
    80004438:	e426                	sd	s1,8(sp)
    8000443a:	e04a                	sd	s2,0(sp)
    8000443c:	1000                	add	s0,sp,32
  acquire(&log.lock);
    8000443e:	0001d517          	auipc	a0,0x1d
    80004442:	16250513          	add	a0,a0,354 # 800215a0 <log>
    80004446:	ffffc097          	auipc	ra,0xffffc
    8000444a:	78c080e7          	jalr	1932(ra) # 80000bd2 <acquire>
  while(1){
    if(log.committing){
    8000444e:	0001d497          	auipc	s1,0x1d
    80004452:	15248493          	add	s1,s1,338 # 800215a0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004456:	4979                	li	s2,30
    80004458:	a039                	j	80004466 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000445a:	85a6                	mv	a1,s1
    8000445c:	8526                	mv	a0,s1
    8000445e:	ffffe097          	auipc	ra,0xffffe
    80004462:	d02080e7          	jalr	-766(ra) # 80002160 <sleep>
    if(log.committing){
    80004466:	50dc                	lw	a5,36(s1)
    80004468:	fbed                	bnez	a5,8000445a <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000446a:	5098                	lw	a4,32(s1)
    8000446c:	2705                	addw	a4,a4,1
    8000446e:	0027179b          	sllw	a5,a4,0x2
    80004472:	9fb9                	addw	a5,a5,a4
    80004474:	0017979b          	sllw	a5,a5,0x1
    80004478:	54d4                	lw	a3,44(s1)
    8000447a:	9fb5                	addw	a5,a5,a3
    8000447c:	00f95963          	bge	s2,a5,8000448e <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004480:	85a6                	mv	a1,s1
    80004482:	8526                	mv	a0,s1
    80004484:	ffffe097          	auipc	ra,0xffffe
    80004488:	cdc080e7          	jalr	-804(ra) # 80002160 <sleep>
    8000448c:	bfe9                	j	80004466 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000448e:	0001d517          	auipc	a0,0x1d
    80004492:	11250513          	add	a0,a0,274 # 800215a0 <log>
    80004496:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80004498:	ffffc097          	auipc	ra,0xffffc
    8000449c:	7ee080e7          	jalr	2030(ra) # 80000c86 <release>
      break;
    }
  }
}
    800044a0:	60e2                	ld	ra,24(sp)
    800044a2:	6442                	ld	s0,16(sp)
    800044a4:	64a2                	ld	s1,8(sp)
    800044a6:	6902                	ld	s2,0(sp)
    800044a8:	6105                	add	sp,sp,32
    800044aa:	8082                	ret

00000000800044ac <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800044ac:	7139                	add	sp,sp,-64
    800044ae:	fc06                	sd	ra,56(sp)
    800044b0:	f822                	sd	s0,48(sp)
    800044b2:	f426                	sd	s1,40(sp)
    800044b4:	f04a                	sd	s2,32(sp)
    800044b6:	ec4e                	sd	s3,24(sp)
    800044b8:	e852                	sd	s4,16(sp)
    800044ba:	e456                	sd	s5,8(sp)
    800044bc:	0080                	add	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800044be:	0001d497          	auipc	s1,0x1d
    800044c2:	0e248493          	add	s1,s1,226 # 800215a0 <log>
    800044c6:	8526                	mv	a0,s1
    800044c8:	ffffc097          	auipc	ra,0xffffc
    800044cc:	70a080e7          	jalr	1802(ra) # 80000bd2 <acquire>
  log.outstanding -= 1;
    800044d0:	509c                	lw	a5,32(s1)
    800044d2:	37fd                	addw	a5,a5,-1
    800044d4:	0007891b          	sext.w	s2,a5
    800044d8:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800044da:	50dc                	lw	a5,36(s1)
    800044dc:	e7b9                	bnez	a5,8000452a <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800044de:	04091e63          	bnez	s2,8000453a <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800044e2:	0001d497          	auipc	s1,0x1d
    800044e6:	0be48493          	add	s1,s1,190 # 800215a0 <log>
    800044ea:	4785                	li	a5,1
    800044ec:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800044ee:	8526                	mv	a0,s1
    800044f0:	ffffc097          	auipc	ra,0xffffc
    800044f4:	796080e7          	jalr	1942(ra) # 80000c86 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800044f8:	54dc                	lw	a5,44(s1)
    800044fa:	06f04763          	bgtz	a5,80004568 <end_op+0xbc>
    acquire(&log.lock);
    800044fe:	0001d497          	auipc	s1,0x1d
    80004502:	0a248493          	add	s1,s1,162 # 800215a0 <log>
    80004506:	8526                	mv	a0,s1
    80004508:	ffffc097          	auipc	ra,0xffffc
    8000450c:	6ca080e7          	jalr	1738(ra) # 80000bd2 <acquire>
    log.committing = 0;
    80004510:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004514:	8526                	mv	a0,s1
    80004516:	ffffe097          	auipc	ra,0xffffe
    8000451a:	dfa080e7          	jalr	-518(ra) # 80002310 <wakeup>
    release(&log.lock);
    8000451e:	8526                	mv	a0,s1
    80004520:	ffffc097          	auipc	ra,0xffffc
    80004524:	766080e7          	jalr	1894(ra) # 80000c86 <release>
}
    80004528:	a03d                	j	80004556 <end_op+0xaa>
    panic("log.committing");
    8000452a:	00004517          	auipc	a0,0x4
    8000452e:	27e50513          	add	a0,a0,638 # 800087a8 <syscalls+0x1f8>
    80004532:	ffffc097          	auipc	ra,0xffffc
    80004536:	00a080e7          	jalr	10(ra) # 8000053c <panic>
    wakeup(&log);
    8000453a:	0001d497          	auipc	s1,0x1d
    8000453e:	06648493          	add	s1,s1,102 # 800215a0 <log>
    80004542:	8526                	mv	a0,s1
    80004544:	ffffe097          	auipc	ra,0xffffe
    80004548:	dcc080e7          	jalr	-564(ra) # 80002310 <wakeup>
  release(&log.lock);
    8000454c:	8526                	mv	a0,s1
    8000454e:	ffffc097          	auipc	ra,0xffffc
    80004552:	738080e7          	jalr	1848(ra) # 80000c86 <release>
}
    80004556:	70e2                	ld	ra,56(sp)
    80004558:	7442                	ld	s0,48(sp)
    8000455a:	74a2                	ld	s1,40(sp)
    8000455c:	7902                	ld	s2,32(sp)
    8000455e:	69e2                	ld	s3,24(sp)
    80004560:	6a42                	ld	s4,16(sp)
    80004562:	6aa2                	ld	s5,8(sp)
    80004564:	6121                	add	sp,sp,64
    80004566:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004568:	0001da97          	auipc	s5,0x1d
    8000456c:	068a8a93          	add	s5,s5,104 # 800215d0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004570:	0001da17          	auipc	s4,0x1d
    80004574:	030a0a13          	add	s4,s4,48 # 800215a0 <log>
    80004578:	018a2583          	lw	a1,24(s4)
    8000457c:	012585bb          	addw	a1,a1,s2
    80004580:	2585                	addw	a1,a1,1
    80004582:	028a2503          	lw	a0,40(s4)
    80004586:	fffff097          	auipc	ra,0xfffff
    8000458a:	cf6080e7          	jalr	-778(ra) # 8000327c <bread>
    8000458e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004590:	000aa583          	lw	a1,0(s5)
    80004594:	028a2503          	lw	a0,40(s4)
    80004598:	fffff097          	auipc	ra,0xfffff
    8000459c:	ce4080e7          	jalr	-796(ra) # 8000327c <bread>
    800045a0:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800045a2:	40000613          	li	a2,1024
    800045a6:	05850593          	add	a1,a0,88
    800045aa:	05848513          	add	a0,s1,88
    800045ae:	ffffc097          	auipc	ra,0xffffc
    800045b2:	77c080e7          	jalr	1916(ra) # 80000d2a <memmove>
    bwrite(to);  // write the log
    800045b6:	8526                	mv	a0,s1
    800045b8:	fffff097          	auipc	ra,0xfffff
    800045bc:	db6080e7          	jalr	-586(ra) # 8000336e <bwrite>
    brelse(from);
    800045c0:	854e                	mv	a0,s3
    800045c2:	fffff097          	auipc	ra,0xfffff
    800045c6:	dea080e7          	jalr	-534(ra) # 800033ac <brelse>
    brelse(to);
    800045ca:	8526                	mv	a0,s1
    800045cc:	fffff097          	auipc	ra,0xfffff
    800045d0:	de0080e7          	jalr	-544(ra) # 800033ac <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800045d4:	2905                	addw	s2,s2,1
    800045d6:	0a91                	add	s5,s5,4
    800045d8:	02ca2783          	lw	a5,44(s4)
    800045dc:	f8f94ee3          	blt	s2,a5,80004578 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800045e0:	00000097          	auipc	ra,0x0
    800045e4:	c8c080e7          	jalr	-884(ra) # 8000426c <write_head>
    install_trans(0); // Now install writes to home locations
    800045e8:	4501                	li	a0,0
    800045ea:	00000097          	auipc	ra,0x0
    800045ee:	cec080e7          	jalr	-788(ra) # 800042d6 <install_trans>
    log.lh.n = 0;
    800045f2:	0001d797          	auipc	a5,0x1d
    800045f6:	fc07ad23          	sw	zero,-38(a5) # 800215cc <log+0x2c>
    write_head();    // Erase the transaction from the log
    800045fa:	00000097          	auipc	ra,0x0
    800045fe:	c72080e7          	jalr	-910(ra) # 8000426c <write_head>
    80004602:	bdf5                	j	800044fe <end_op+0x52>

0000000080004604 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004604:	1101                	add	sp,sp,-32
    80004606:	ec06                	sd	ra,24(sp)
    80004608:	e822                	sd	s0,16(sp)
    8000460a:	e426                	sd	s1,8(sp)
    8000460c:	e04a                	sd	s2,0(sp)
    8000460e:	1000                	add	s0,sp,32
    80004610:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004612:	0001d917          	auipc	s2,0x1d
    80004616:	f8e90913          	add	s2,s2,-114 # 800215a0 <log>
    8000461a:	854a                	mv	a0,s2
    8000461c:	ffffc097          	auipc	ra,0xffffc
    80004620:	5b6080e7          	jalr	1462(ra) # 80000bd2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004624:	02c92603          	lw	a2,44(s2)
    80004628:	47f5                	li	a5,29
    8000462a:	06c7c563          	blt	a5,a2,80004694 <log_write+0x90>
    8000462e:	0001d797          	auipc	a5,0x1d
    80004632:	f8e7a783          	lw	a5,-114(a5) # 800215bc <log+0x1c>
    80004636:	37fd                	addw	a5,a5,-1
    80004638:	04f65e63          	bge	a2,a5,80004694 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000463c:	0001d797          	auipc	a5,0x1d
    80004640:	f847a783          	lw	a5,-124(a5) # 800215c0 <log+0x20>
    80004644:	06f05063          	blez	a5,800046a4 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004648:	4781                	li	a5,0
    8000464a:	06c05563          	blez	a2,800046b4 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000464e:	44cc                	lw	a1,12(s1)
    80004650:	0001d717          	auipc	a4,0x1d
    80004654:	f8070713          	add	a4,a4,-128 # 800215d0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004658:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000465a:	4314                	lw	a3,0(a4)
    8000465c:	04b68c63          	beq	a3,a1,800046b4 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004660:	2785                	addw	a5,a5,1
    80004662:	0711                	add	a4,a4,4
    80004664:	fef61be3          	bne	a2,a5,8000465a <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004668:	0621                	add	a2,a2,8
    8000466a:	060a                	sll	a2,a2,0x2
    8000466c:	0001d797          	auipc	a5,0x1d
    80004670:	f3478793          	add	a5,a5,-204 # 800215a0 <log>
    80004674:	97b2                	add	a5,a5,a2
    80004676:	44d8                	lw	a4,12(s1)
    80004678:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000467a:	8526                	mv	a0,s1
    8000467c:	fffff097          	auipc	ra,0xfffff
    80004680:	dcc080e7          	jalr	-564(ra) # 80003448 <bpin>
    log.lh.n++;
    80004684:	0001d717          	auipc	a4,0x1d
    80004688:	f1c70713          	add	a4,a4,-228 # 800215a0 <log>
    8000468c:	575c                	lw	a5,44(a4)
    8000468e:	2785                	addw	a5,a5,1
    80004690:	d75c                	sw	a5,44(a4)
    80004692:	a82d                	j	800046cc <log_write+0xc8>
    panic("too big a transaction");
    80004694:	00004517          	auipc	a0,0x4
    80004698:	12450513          	add	a0,a0,292 # 800087b8 <syscalls+0x208>
    8000469c:	ffffc097          	auipc	ra,0xffffc
    800046a0:	ea0080e7          	jalr	-352(ra) # 8000053c <panic>
    panic("log_write outside of trans");
    800046a4:	00004517          	auipc	a0,0x4
    800046a8:	12c50513          	add	a0,a0,300 # 800087d0 <syscalls+0x220>
    800046ac:	ffffc097          	auipc	ra,0xffffc
    800046b0:	e90080e7          	jalr	-368(ra) # 8000053c <panic>
  log.lh.block[i] = b->blockno;
    800046b4:	00878693          	add	a3,a5,8
    800046b8:	068a                	sll	a3,a3,0x2
    800046ba:	0001d717          	auipc	a4,0x1d
    800046be:	ee670713          	add	a4,a4,-282 # 800215a0 <log>
    800046c2:	9736                	add	a4,a4,a3
    800046c4:	44d4                	lw	a3,12(s1)
    800046c6:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800046c8:	faf609e3          	beq	a2,a5,8000467a <log_write+0x76>
  }
  release(&log.lock);
    800046cc:	0001d517          	auipc	a0,0x1d
    800046d0:	ed450513          	add	a0,a0,-300 # 800215a0 <log>
    800046d4:	ffffc097          	auipc	ra,0xffffc
    800046d8:	5b2080e7          	jalr	1458(ra) # 80000c86 <release>
}
    800046dc:	60e2                	ld	ra,24(sp)
    800046de:	6442                	ld	s0,16(sp)
    800046e0:	64a2                	ld	s1,8(sp)
    800046e2:	6902                	ld	s2,0(sp)
    800046e4:	6105                	add	sp,sp,32
    800046e6:	8082                	ret

00000000800046e8 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800046e8:	1101                	add	sp,sp,-32
    800046ea:	ec06                	sd	ra,24(sp)
    800046ec:	e822                	sd	s0,16(sp)
    800046ee:	e426                	sd	s1,8(sp)
    800046f0:	e04a                	sd	s2,0(sp)
    800046f2:	1000                	add	s0,sp,32
    800046f4:	84aa                	mv	s1,a0
    800046f6:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800046f8:	00004597          	auipc	a1,0x4
    800046fc:	0f858593          	add	a1,a1,248 # 800087f0 <syscalls+0x240>
    80004700:	0521                	add	a0,a0,8
    80004702:	ffffc097          	auipc	ra,0xffffc
    80004706:	440080e7          	jalr	1088(ra) # 80000b42 <initlock>
  lk->name = name;
    8000470a:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000470e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004712:	0204a423          	sw	zero,40(s1)
}
    80004716:	60e2                	ld	ra,24(sp)
    80004718:	6442                	ld	s0,16(sp)
    8000471a:	64a2                	ld	s1,8(sp)
    8000471c:	6902                	ld	s2,0(sp)
    8000471e:	6105                	add	sp,sp,32
    80004720:	8082                	ret

0000000080004722 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004722:	1101                	add	sp,sp,-32
    80004724:	ec06                	sd	ra,24(sp)
    80004726:	e822                	sd	s0,16(sp)
    80004728:	e426                	sd	s1,8(sp)
    8000472a:	e04a                	sd	s2,0(sp)
    8000472c:	1000                	add	s0,sp,32
    8000472e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004730:	00850913          	add	s2,a0,8
    80004734:	854a                	mv	a0,s2
    80004736:	ffffc097          	auipc	ra,0xffffc
    8000473a:	49c080e7          	jalr	1180(ra) # 80000bd2 <acquire>
  while (lk->locked) {
    8000473e:	409c                	lw	a5,0(s1)
    80004740:	cb89                	beqz	a5,80004752 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004742:	85ca                	mv	a1,s2
    80004744:	8526                	mv	a0,s1
    80004746:	ffffe097          	auipc	ra,0xffffe
    8000474a:	a1a080e7          	jalr	-1510(ra) # 80002160 <sleep>
  while (lk->locked) {
    8000474e:	409c                	lw	a5,0(s1)
    80004750:	fbed                	bnez	a5,80004742 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004752:	4785                	li	a5,1
    80004754:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004756:	ffffd097          	auipc	ra,0xffffd
    8000475a:	250080e7          	jalr	592(ra) # 800019a6 <myproc>
    8000475e:	591c                	lw	a5,48(a0)
    80004760:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004762:	854a                	mv	a0,s2
    80004764:	ffffc097          	auipc	ra,0xffffc
    80004768:	522080e7          	jalr	1314(ra) # 80000c86 <release>
}
    8000476c:	60e2                	ld	ra,24(sp)
    8000476e:	6442                	ld	s0,16(sp)
    80004770:	64a2                	ld	s1,8(sp)
    80004772:	6902                	ld	s2,0(sp)
    80004774:	6105                	add	sp,sp,32
    80004776:	8082                	ret

0000000080004778 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004778:	1101                	add	sp,sp,-32
    8000477a:	ec06                	sd	ra,24(sp)
    8000477c:	e822                	sd	s0,16(sp)
    8000477e:	e426                	sd	s1,8(sp)
    80004780:	e04a                	sd	s2,0(sp)
    80004782:	1000                	add	s0,sp,32
    80004784:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004786:	00850913          	add	s2,a0,8
    8000478a:	854a                	mv	a0,s2
    8000478c:	ffffc097          	auipc	ra,0xffffc
    80004790:	446080e7          	jalr	1094(ra) # 80000bd2 <acquire>
  lk->locked = 0;
    80004794:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004798:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000479c:	8526                	mv	a0,s1
    8000479e:	ffffe097          	auipc	ra,0xffffe
    800047a2:	b72080e7          	jalr	-1166(ra) # 80002310 <wakeup>
  release(&lk->lk);
    800047a6:	854a                	mv	a0,s2
    800047a8:	ffffc097          	auipc	ra,0xffffc
    800047ac:	4de080e7          	jalr	1246(ra) # 80000c86 <release>
}
    800047b0:	60e2                	ld	ra,24(sp)
    800047b2:	6442                	ld	s0,16(sp)
    800047b4:	64a2                	ld	s1,8(sp)
    800047b6:	6902                	ld	s2,0(sp)
    800047b8:	6105                	add	sp,sp,32
    800047ba:	8082                	ret

00000000800047bc <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800047bc:	7179                	add	sp,sp,-48
    800047be:	f406                	sd	ra,40(sp)
    800047c0:	f022                	sd	s0,32(sp)
    800047c2:	ec26                	sd	s1,24(sp)
    800047c4:	e84a                	sd	s2,16(sp)
    800047c6:	e44e                	sd	s3,8(sp)
    800047c8:	1800                	add	s0,sp,48
    800047ca:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800047cc:	00850913          	add	s2,a0,8
    800047d0:	854a                	mv	a0,s2
    800047d2:	ffffc097          	auipc	ra,0xffffc
    800047d6:	400080e7          	jalr	1024(ra) # 80000bd2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800047da:	409c                	lw	a5,0(s1)
    800047dc:	ef99                	bnez	a5,800047fa <holdingsleep+0x3e>
    800047de:	4481                	li	s1,0
  release(&lk->lk);
    800047e0:	854a                	mv	a0,s2
    800047e2:	ffffc097          	auipc	ra,0xffffc
    800047e6:	4a4080e7          	jalr	1188(ra) # 80000c86 <release>
  return r;
}
    800047ea:	8526                	mv	a0,s1
    800047ec:	70a2                	ld	ra,40(sp)
    800047ee:	7402                	ld	s0,32(sp)
    800047f0:	64e2                	ld	s1,24(sp)
    800047f2:	6942                	ld	s2,16(sp)
    800047f4:	69a2                	ld	s3,8(sp)
    800047f6:	6145                	add	sp,sp,48
    800047f8:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800047fa:	0284a983          	lw	s3,40(s1)
    800047fe:	ffffd097          	auipc	ra,0xffffd
    80004802:	1a8080e7          	jalr	424(ra) # 800019a6 <myproc>
    80004806:	5904                	lw	s1,48(a0)
    80004808:	413484b3          	sub	s1,s1,s3
    8000480c:	0014b493          	seqz	s1,s1
    80004810:	bfc1                	j	800047e0 <holdingsleep+0x24>

0000000080004812 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004812:	1141                	add	sp,sp,-16
    80004814:	e406                	sd	ra,8(sp)
    80004816:	e022                	sd	s0,0(sp)
    80004818:	0800                	add	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000481a:	00004597          	auipc	a1,0x4
    8000481e:	fe658593          	add	a1,a1,-26 # 80008800 <syscalls+0x250>
    80004822:	0001d517          	auipc	a0,0x1d
    80004826:	ec650513          	add	a0,a0,-314 # 800216e8 <ftable>
    8000482a:	ffffc097          	auipc	ra,0xffffc
    8000482e:	318080e7          	jalr	792(ra) # 80000b42 <initlock>
}
    80004832:	60a2                	ld	ra,8(sp)
    80004834:	6402                	ld	s0,0(sp)
    80004836:	0141                	add	sp,sp,16
    80004838:	8082                	ret

000000008000483a <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000483a:	1101                	add	sp,sp,-32
    8000483c:	ec06                	sd	ra,24(sp)
    8000483e:	e822                	sd	s0,16(sp)
    80004840:	e426                	sd	s1,8(sp)
    80004842:	1000                	add	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004844:	0001d517          	auipc	a0,0x1d
    80004848:	ea450513          	add	a0,a0,-348 # 800216e8 <ftable>
    8000484c:	ffffc097          	auipc	ra,0xffffc
    80004850:	386080e7          	jalr	902(ra) # 80000bd2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004854:	0001d497          	auipc	s1,0x1d
    80004858:	eac48493          	add	s1,s1,-340 # 80021700 <ftable+0x18>
    8000485c:	0001e717          	auipc	a4,0x1e
    80004860:	e4470713          	add	a4,a4,-444 # 800226a0 <disk>
    if(f->ref == 0){
    80004864:	40dc                	lw	a5,4(s1)
    80004866:	cf99                	beqz	a5,80004884 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004868:	02848493          	add	s1,s1,40
    8000486c:	fee49ce3          	bne	s1,a4,80004864 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004870:	0001d517          	auipc	a0,0x1d
    80004874:	e7850513          	add	a0,a0,-392 # 800216e8 <ftable>
    80004878:	ffffc097          	auipc	ra,0xffffc
    8000487c:	40e080e7          	jalr	1038(ra) # 80000c86 <release>
  return 0;
    80004880:	4481                	li	s1,0
    80004882:	a819                	j	80004898 <filealloc+0x5e>
      f->ref = 1;
    80004884:	4785                	li	a5,1
    80004886:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004888:	0001d517          	auipc	a0,0x1d
    8000488c:	e6050513          	add	a0,a0,-416 # 800216e8 <ftable>
    80004890:	ffffc097          	auipc	ra,0xffffc
    80004894:	3f6080e7          	jalr	1014(ra) # 80000c86 <release>
}
    80004898:	8526                	mv	a0,s1
    8000489a:	60e2                	ld	ra,24(sp)
    8000489c:	6442                	ld	s0,16(sp)
    8000489e:	64a2                	ld	s1,8(sp)
    800048a0:	6105                	add	sp,sp,32
    800048a2:	8082                	ret

00000000800048a4 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800048a4:	1101                	add	sp,sp,-32
    800048a6:	ec06                	sd	ra,24(sp)
    800048a8:	e822                	sd	s0,16(sp)
    800048aa:	e426                	sd	s1,8(sp)
    800048ac:	1000                	add	s0,sp,32
    800048ae:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800048b0:	0001d517          	auipc	a0,0x1d
    800048b4:	e3850513          	add	a0,a0,-456 # 800216e8 <ftable>
    800048b8:	ffffc097          	auipc	ra,0xffffc
    800048bc:	31a080e7          	jalr	794(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    800048c0:	40dc                	lw	a5,4(s1)
    800048c2:	02f05263          	blez	a5,800048e6 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800048c6:	2785                	addw	a5,a5,1
    800048c8:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800048ca:	0001d517          	auipc	a0,0x1d
    800048ce:	e1e50513          	add	a0,a0,-482 # 800216e8 <ftable>
    800048d2:	ffffc097          	auipc	ra,0xffffc
    800048d6:	3b4080e7          	jalr	948(ra) # 80000c86 <release>
  return f;
}
    800048da:	8526                	mv	a0,s1
    800048dc:	60e2                	ld	ra,24(sp)
    800048de:	6442                	ld	s0,16(sp)
    800048e0:	64a2                	ld	s1,8(sp)
    800048e2:	6105                	add	sp,sp,32
    800048e4:	8082                	ret
    panic("filedup");
    800048e6:	00004517          	auipc	a0,0x4
    800048ea:	f2250513          	add	a0,a0,-222 # 80008808 <syscalls+0x258>
    800048ee:	ffffc097          	auipc	ra,0xffffc
    800048f2:	c4e080e7          	jalr	-946(ra) # 8000053c <panic>

00000000800048f6 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800048f6:	7139                	add	sp,sp,-64
    800048f8:	fc06                	sd	ra,56(sp)
    800048fa:	f822                	sd	s0,48(sp)
    800048fc:	f426                	sd	s1,40(sp)
    800048fe:	f04a                	sd	s2,32(sp)
    80004900:	ec4e                	sd	s3,24(sp)
    80004902:	e852                	sd	s4,16(sp)
    80004904:	e456                	sd	s5,8(sp)
    80004906:	0080                	add	s0,sp,64
    80004908:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000490a:	0001d517          	auipc	a0,0x1d
    8000490e:	dde50513          	add	a0,a0,-546 # 800216e8 <ftable>
    80004912:	ffffc097          	auipc	ra,0xffffc
    80004916:	2c0080e7          	jalr	704(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    8000491a:	40dc                	lw	a5,4(s1)
    8000491c:	06f05163          	blez	a5,8000497e <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004920:	37fd                	addw	a5,a5,-1
    80004922:	0007871b          	sext.w	a4,a5
    80004926:	c0dc                	sw	a5,4(s1)
    80004928:	06e04363          	bgtz	a4,8000498e <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000492c:	0004a903          	lw	s2,0(s1)
    80004930:	0094ca83          	lbu	s5,9(s1)
    80004934:	0104ba03          	ld	s4,16(s1)
    80004938:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000493c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004940:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004944:	0001d517          	auipc	a0,0x1d
    80004948:	da450513          	add	a0,a0,-604 # 800216e8 <ftable>
    8000494c:	ffffc097          	auipc	ra,0xffffc
    80004950:	33a080e7          	jalr	826(ra) # 80000c86 <release>

  if(ff.type == FD_PIPE){
    80004954:	4785                	li	a5,1
    80004956:	04f90d63          	beq	s2,a5,800049b0 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000495a:	3979                	addw	s2,s2,-2
    8000495c:	4785                	li	a5,1
    8000495e:	0527e063          	bltu	a5,s2,8000499e <fileclose+0xa8>
    begin_op();
    80004962:	00000097          	auipc	ra,0x0
    80004966:	ad0080e7          	jalr	-1328(ra) # 80004432 <begin_op>
    iput(ff.ip);
    8000496a:	854e                	mv	a0,s3
    8000496c:	fffff097          	auipc	ra,0xfffff
    80004970:	2da080e7          	jalr	730(ra) # 80003c46 <iput>
    end_op();
    80004974:	00000097          	auipc	ra,0x0
    80004978:	b38080e7          	jalr	-1224(ra) # 800044ac <end_op>
    8000497c:	a00d                	j	8000499e <fileclose+0xa8>
    panic("fileclose");
    8000497e:	00004517          	auipc	a0,0x4
    80004982:	e9250513          	add	a0,a0,-366 # 80008810 <syscalls+0x260>
    80004986:	ffffc097          	auipc	ra,0xffffc
    8000498a:	bb6080e7          	jalr	-1098(ra) # 8000053c <panic>
    release(&ftable.lock);
    8000498e:	0001d517          	auipc	a0,0x1d
    80004992:	d5a50513          	add	a0,a0,-678 # 800216e8 <ftable>
    80004996:	ffffc097          	auipc	ra,0xffffc
    8000499a:	2f0080e7          	jalr	752(ra) # 80000c86 <release>
  }
}
    8000499e:	70e2                	ld	ra,56(sp)
    800049a0:	7442                	ld	s0,48(sp)
    800049a2:	74a2                	ld	s1,40(sp)
    800049a4:	7902                	ld	s2,32(sp)
    800049a6:	69e2                	ld	s3,24(sp)
    800049a8:	6a42                	ld	s4,16(sp)
    800049aa:	6aa2                	ld	s5,8(sp)
    800049ac:	6121                	add	sp,sp,64
    800049ae:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800049b0:	85d6                	mv	a1,s5
    800049b2:	8552                	mv	a0,s4
    800049b4:	00000097          	auipc	ra,0x0
    800049b8:	348080e7          	jalr	840(ra) # 80004cfc <pipeclose>
    800049bc:	b7cd                	j	8000499e <fileclose+0xa8>

00000000800049be <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800049be:	715d                	add	sp,sp,-80
    800049c0:	e486                	sd	ra,72(sp)
    800049c2:	e0a2                	sd	s0,64(sp)
    800049c4:	fc26                	sd	s1,56(sp)
    800049c6:	f84a                	sd	s2,48(sp)
    800049c8:	f44e                	sd	s3,40(sp)
    800049ca:	0880                	add	s0,sp,80
    800049cc:	84aa                	mv	s1,a0
    800049ce:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800049d0:	ffffd097          	auipc	ra,0xffffd
    800049d4:	fd6080e7          	jalr	-42(ra) # 800019a6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800049d8:	409c                	lw	a5,0(s1)
    800049da:	37f9                	addw	a5,a5,-2
    800049dc:	4705                	li	a4,1
    800049de:	04f76763          	bltu	a4,a5,80004a2c <filestat+0x6e>
    800049e2:	892a                	mv	s2,a0
    ilock(f->ip);
    800049e4:	6c88                	ld	a0,24(s1)
    800049e6:	fffff097          	auipc	ra,0xfffff
    800049ea:	0a6080e7          	jalr	166(ra) # 80003a8c <ilock>
    stati(f->ip, &st);
    800049ee:	fb840593          	add	a1,s0,-72
    800049f2:	6c88                	ld	a0,24(s1)
    800049f4:	fffff097          	auipc	ra,0xfffff
    800049f8:	322080e7          	jalr	802(ra) # 80003d16 <stati>
    iunlock(f->ip);
    800049fc:	6c88                	ld	a0,24(s1)
    800049fe:	fffff097          	auipc	ra,0xfffff
    80004a02:	150080e7          	jalr	336(ra) # 80003b4e <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004a06:	46e1                	li	a3,24
    80004a08:	fb840613          	add	a2,s0,-72
    80004a0c:	85ce                	mv	a1,s3
    80004a0e:	05093503          	ld	a0,80(s2)
    80004a12:	ffffd097          	auipc	ra,0xffffd
    80004a16:	c54080e7          	jalr	-940(ra) # 80001666 <copyout>
    80004a1a:	41f5551b          	sraw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004a1e:	60a6                	ld	ra,72(sp)
    80004a20:	6406                	ld	s0,64(sp)
    80004a22:	74e2                	ld	s1,56(sp)
    80004a24:	7942                	ld	s2,48(sp)
    80004a26:	79a2                	ld	s3,40(sp)
    80004a28:	6161                	add	sp,sp,80
    80004a2a:	8082                	ret
  return -1;
    80004a2c:	557d                	li	a0,-1
    80004a2e:	bfc5                	j	80004a1e <filestat+0x60>

0000000080004a30 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004a30:	7179                	add	sp,sp,-48
    80004a32:	f406                	sd	ra,40(sp)
    80004a34:	f022                	sd	s0,32(sp)
    80004a36:	ec26                	sd	s1,24(sp)
    80004a38:	e84a                	sd	s2,16(sp)
    80004a3a:	e44e                	sd	s3,8(sp)
    80004a3c:	1800                	add	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004a3e:	00854783          	lbu	a5,8(a0)
    80004a42:	c3d5                	beqz	a5,80004ae6 <fileread+0xb6>
    80004a44:	84aa                	mv	s1,a0
    80004a46:	89ae                	mv	s3,a1
    80004a48:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004a4a:	411c                	lw	a5,0(a0)
    80004a4c:	4705                	li	a4,1
    80004a4e:	04e78963          	beq	a5,a4,80004aa0 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004a52:	470d                	li	a4,3
    80004a54:	04e78d63          	beq	a5,a4,80004aae <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004a58:	4709                	li	a4,2
    80004a5a:	06e79e63          	bne	a5,a4,80004ad6 <fileread+0xa6>
    ilock(f->ip);
    80004a5e:	6d08                	ld	a0,24(a0)
    80004a60:	fffff097          	auipc	ra,0xfffff
    80004a64:	02c080e7          	jalr	44(ra) # 80003a8c <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004a68:	874a                	mv	a4,s2
    80004a6a:	5094                	lw	a3,32(s1)
    80004a6c:	864e                	mv	a2,s3
    80004a6e:	4585                	li	a1,1
    80004a70:	6c88                	ld	a0,24(s1)
    80004a72:	fffff097          	auipc	ra,0xfffff
    80004a76:	2ce080e7          	jalr	718(ra) # 80003d40 <readi>
    80004a7a:	892a                	mv	s2,a0
    80004a7c:	00a05563          	blez	a0,80004a86 <fileread+0x56>
      f->off += r;
    80004a80:	509c                	lw	a5,32(s1)
    80004a82:	9fa9                	addw	a5,a5,a0
    80004a84:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004a86:	6c88                	ld	a0,24(s1)
    80004a88:	fffff097          	auipc	ra,0xfffff
    80004a8c:	0c6080e7          	jalr	198(ra) # 80003b4e <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004a90:	854a                	mv	a0,s2
    80004a92:	70a2                	ld	ra,40(sp)
    80004a94:	7402                	ld	s0,32(sp)
    80004a96:	64e2                	ld	s1,24(sp)
    80004a98:	6942                	ld	s2,16(sp)
    80004a9a:	69a2                	ld	s3,8(sp)
    80004a9c:	6145                	add	sp,sp,48
    80004a9e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004aa0:	6908                	ld	a0,16(a0)
    80004aa2:	00000097          	auipc	ra,0x0
    80004aa6:	3c2080e7          	jalr	962(ra) # 80004e64 <piperead>
    80004aaa:	892a                	mv	s2,a0
    80004aac:	b7d5                	j	80004a90 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004aae:	02451783          	lh	a5,36(a0)
    80004ab2:	03079693          	sll	a3,a5,0x30
    80004ab6:	92c1                	srl	a3,a3,0x30
    80004ab8:	4725                	li	a4,9
    80004aba:	02d76863          	bltu	a4,a3,80004aea <fileread+0xba>
    80004abe:	0792                	sll	a5,a5,0x4
    80004ac0:	0001d717          	auipc	a4,0x1d
    80004ac4:	b8870713          	add	a4,a4,-1144 # 80021648 <devsw>
    80004ac8:	97ba                	add	a5,a5,a4
    80004aca:	639c                	ld	a5,0(a5)
    80004acc:	c38d                	beqz	a5,80004aee <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004ace:	4505                	li	a0,1
    80004ad0:	9782                	jalr	a5
    80004ad2:	892a                	mv	s2,a0
    80004ad4:	bf75                	j	80004a90 <fileread+0x60>
    panic("fileread");
    80004ad6:	00004517          	auipc	a0,0x4
    80004ada:	d4a50513          	add	a0,a0,-694 # 80008820 <syscalls+0x270>
    80004ade:	ffffc097          	auipc	ra,0xffffc
    80004ae2:	a5e080e7          	jalr	-1442(ra) # 8000053c <panic>
    return -1;
    80004ae6:	597d                	li	s2,-1
    80004ae8:	b765                	j	80004a90 <fileread+0x60>
      return -1;
    80004aea:	597d                	li	s2,-1
    80004aec:	b755                	j	80004a90 <fileread+0x60>
    80004aee:	597d                	li	s2,-1
    80004af0:	b745                	j	80004a90 <fileread+0x60>

0000000080004af2 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004af2:	00954783          	lbu	a5,9(a0)
    80004af6:	10078e63          	beqz	a5,80004c12 <filewrite+0x120>
{
    80004afa:	715d                	add	sp,sp,-80
    80004afc:	e486                	sd	ra,72(sp)
    80004afe:	e0a2                	sd	s0,64(sp)
    80004b00:	fc26                	sd	s1,56(sp)
    80004b02:	f84a                	sd	s2,48(sp)
    80004b04:	f44e                	sd	s3,40(sp)
    80004b06:	f052                	sd	s4,32(sp)
    80004b08:	ec56                	sd	s5,24(sp)
    80004b0a:	e85a                	sd	s6,16(sp)
    80004b0c:	e45e                	sd	s7,8(sp)
    80004b0e:	e062                	sd	s8,0(sp)
    80004b10:	0880                	add	s0,sp,80
    80004b12:	892a                	mv	s2,a0
    80004b14:	8b2e                	mv	s6,a1
    80004b16:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004b18:	411c                	lw	a5,0(a0)
    80004b1a:	4705                	li	a4,1
    80004b1c:	02e78263          	beq	a5,a4,80004b40 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004b20:	470d                	li	a4,3
    80004b22:	02e78563          	beq	a5,a4,80004b4c <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004b26:	4709                	li	a4,2
    80004b28:	0ce79d63          	bne	a5,a4,80004c02 <filewrite+0x110>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004b2c:	0ac05b63          	blez	a2,80004be2 <filewrite+0xf0>
    int i = 0;
    80004b30:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004b32:	6b85                	lui	s7,0x1
    80004b34:	c00b8b93          	add	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004b38:	6c05                	lui	s8,0x1
    80004b3a:	c00c0c1b          	addw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004b3e:	a851                	j	80004bd2 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004b40:	6908                	ld	a0,16(a0)
    80004b42:	00000097          	auipc	ra,0x0
    80004b46:	22a080e7          	jalr	554(ra) # 80004d6c <pipewrite>
    80004b4a:	a045                	j	80004bea <filewrite+0xf8>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004b4c:	02451783          	lh	a5,36(a0)
    80004b50:	03079693          	sll	a3,a5,0x30
    80004b54:	92c1                	srl	a3,a3,0x30
    80004b56:	4725                	li	a4,9
    80004b58:	0ad76f63          	bltu	a4,a3,80004c16 <filewrite+0x124>
    80004b5c:	0792                	sll	a5,a5,0x4
    80004b5e:	0001d717          	auipc	a4,0x1d
    80004b62:	aea70713          	add	a4,a4,-1302 # 80021648 <devsw>
    80004b66:	97ba                	add	a5,a5,a4
    80004b68:	679c                	ld	a5,8(a5)
    80004b6a:	cbc5                	beqz	a5,80004c1a <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    80004b6c:	4505                	li	a0,1
    80004b6e:	9782                	jalr	a5
    80004b70:	a8ad                	j	80004bea <filewrite+0xf8>
      if(n1 > max)
    80004b72:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004b76:	00000097          	auipc	ra,0x0
    80004b7a:	8bc080e7          	jalr	-1860(ra) # 80004432 <begin_op>
      ilock(f->ip);
    80004b7e:	01893503          	ld	a0,24(s2)
    80004b82:	fffff097          	auipc	ra,0xfffff
    80004b86:	f0a080e7          	jalr	-246(ra) # 80003a8c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004b8a:	8756                	mv	a4,s5
    80004b8c:	02092683          	lw	a3,32(s2)
    80004b90:	01698633          	add	a2,s3,s6
    80004b94:	4585                	li	a1,1
    80004b96:	01893503          	ld	a0,24(s2)
    80004b9a:	fffff097          	auipc	ra,0xfffff
    80004b9e:	29e080e7          	jalr	670(ra) # 80003e38 <writei>
    80004ba2:	84aa                	mv	s1,a0
    80004ba4:	00a05763          	blez	a0,80004bb2 <filewrite+0xc0>
        f->off += r;
    80004ba8:	02092783          	lw	a5,32(s2)
    80004bac:	9fa9                	addw	a5,a5,a0
    80004bae:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004bb2:	01893503          	ld	a0,24(s2)
    80004bb6:	fffff097          	auipc	ra,0xfffff
    80004bba:	f98080e7          	jalr	-104(ra) # 80003b4e <iunlock>
      end_op();
    80004bbe:	00000097          	auipc	ra,0x0
    80004bc2:	8ee080e7          	jalr	-1810(ra) # 800044ac <end_op>

      if(r != n1){
    80004bc6:	009a9f63          	bne	s5,s1,80004be4 <filewrite+0xf2>
        // error from writei
        break;
      }
      i += r;
    80004bca:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004bce:	0149db63          	bge	s3,s4,80004be4 <filewrite+0xf2>
      int n1 = n - i;
    80004bd2:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004bd6:	0004879b          	sext.w	a5,s1
    80004bda:	f8fbdce3          	bge	s7,a5,80004b72 <filewrite+0x80>
    80004bde:	84e2                	mv	s1,s8
    80004be0:	bf49                	j	80004b72 <filewrite+0x80>
    int i = 0;
    80004be2:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004be4:	033a1d63          	bne	s4,s3,80004c1e <filewrite+0x12c>
    80004be8:	8552                	mv	a0,s4
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004bea:	60a6                	ld	ra,72(sp)
    80004bec:	6406                	ld	s0,64(sp)
    80004bee:	74e2                	ld	s1,56(sp)
    80004bf0:	7942                	ld	s2,48(sp)
    80004bf2:	79a2                	ld	s3,40(sp)
    80004bf4:	7a02                	ld	s4,32(sp)
    80004bf6:	6ae2                	ld	s5,24(sp)
    80004bf8:	6b42                	ld	s6,16(sp)
    80004bfa:	6ba2                	ld	s7,8(sp)
    80004bfc:	6c02                	ld	s8,0(sp)
    80004bfe:	6161                	add	sp,sp,80
    80004c00:	8082                	ret
    panic("filewrite");
    80004c02:	00004517          	auipc	a0,0x4
    80004c06:	c2e50513          	add	a0,a0,-978 # 80008830 <syscalls+0x280>
    80004c0a:	ffffc097          	auipc	ra,0xffffc
    80004c0e:	932080e7          	jalr	-1742(ra) # 8000053c <panic>
    return -1;
    80004c12:	557d                	li	a0,-1
}
    80004c14:	8082                	ret
      return -1;
    80004c16:	557d                	li	a0,-1
    80004c18:	bfc9                	j	80004bea <filewrite+0xf8>
    80004c1a:	557d                	li	a0,-1
    80004c1c:	b7f9                	j	80004bea <filewrite+0xf8>
    ret = (i == n ? n : -1);
    80004c1e:	557d                	li	a0,-1
    80004c20:	b7e9                	j	80004bea <filewrite+0xf8>

0000000080004c22 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004c22:	7179                	add	sp,sp,-48
    80004c24:	f406                	sd	ra,40(sp)
    80004c26:	f022                	sd	s0,32(sp)
    80004c28:	ec26                	sd	s1,24(sp)
    80004c2a:	e84a                	sd	s2,16(sp)
    80004c2c:	e44e                	sd	s3,8(sp)
    80004c2e:	e052                	sd	s4,0(sp)
    80004c30:	1800                	add	s0,sp,48
    80004c32:	84aa                	mv	s1,a0
    80004c34:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004c36:	0005b023          	sd	zero,0(a1)
    80004c3a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004c3e:	00000097          	auipc	ra,0x0
    80004c42:	bfc080e7          	jalr	-1028(ra) # 8000483a <filealloc>
    80004c46:	e088                	sd	a0,0(s1)
    80004c48:	c551                	beqz	a0,80004cd4 <pipealloc+0xb2>
    80004c4a:	00000097          	auipc	ra,0x0
    80004c4e:	bf0080e7          	jalr	-1040(ra) # 8000483a <filealloc>
    80004c52:	00aa3023          	sd	a0,0(s4)
    80004c56:	c92d                	beqz	a0,80004cc8 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004c58:	ffffc097          	auipc	ra,0xffffc
    80004c5c:	e8a080e7          	jalr	-374(ra) # 80000ae2 <kalloc>
    80004c60:	892a                	mv	s2,a0
    80004c62:	c125                	beqz	a0,80004cc2 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004c64:	4985                	li	s3,1
    80004c66:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004c6a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004c6e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004c72:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004c76:	00004597          	auipc	a1,0x4
    80004c7a:	87a58593          	add	a1,a1,-1926 # 800084f0 <states.0+0x208>
    80004c7e:	ffffc097          	auipc	ra,0xffffc
    80004c82:	ec4080e7          	jalr	-316(ra) # 80000b42 <initlock>
  (*f0)->type = FD_PIPE;
    80004c86:	609c                	ld	a5,0(s1)
    80004c88:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004c8c:	609c                	ld	a5,0(s1)
    80004c8e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004c92:	609c                	ld	a5,0(s1)
    80004c94:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004c98:	609c                	ld	a5,0(s1)
    80004c9a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004c9e:	000a3783          	ld	a5,0(s4)
    80004ca2:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004ca6:	000a3783          	ld	a5,0(s4)
    80004caa:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004cae:	000a3783          	ld	a5,0(s4)
    80004cb2:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004cb6:	000a3783          	ld	a5,0(s4)
    80004cba:	0127b823          	sd	s2,16(a5)
  return 0;
    80004cbe:	4501                	li	a0,0
    80004cc0:	a025                	j	80004ce8 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004cc2:	6088                	ld	a0,0(s1)
    80004cc4:	e501                	bnez	a0,80004ccc <pipealloc+0xaa>
    80004cc6:	a039                	j	80004cd4 <pipealloc+0xb2>
    80004cc8:	6088                	ld	a0,0(s1)
    80004cca:	c51d                	beqz	a0,80004cf8 <pipealloc+0xd6>
    fileclose(*f0);
    80004ccc:	00000097          	auipc	ra,0x0
    80004cd0:	c2a080e7          	jalr	-982(ra) # 800048f6 <fileclose>
  if(*f1)
    80004cd4:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004cd8:	557d                	li	a0,-1
  if(*f1)
    80004cda:	c799                	beqz	a5,80004ce8 <pipealloc+0xc6>
    fileclose(*f1);
    80004cdc:	853e                	mv	a0,a5
    80004cde:	00000097          	auipc	ra,0x0
    80004ce2:	c18080e7          	jalr	-1000(ra) # 800048f6 <fileclose>
  return -1;
    80004ce6:	557d                	li	a0,-1
}
    80004ce8:	70a2                	ld	ra,40(sp)
    80004cea:	7402                	ld	s0,32(sp)
    80004cec:	64e2                	ld	s1,24(sp)
    80004cee:	6942                	ld	s2,16(sp)
    80004cf0:	69a2                	ld	s3,8(sp)
    80004cf2:	6a02                	ld	s4,0(sp)
    80004cf4:	6145                	add	sp,sp,48
    80004cf6:	8082                	ret
  return -1;
    80004cf8:	557d                	li	a0,-1
    80004cfa:	b7fd                	j	80004ce8 <pipealloc+0xc6>

0000000080004cfc <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004cfc:	1101                	add	sp,sp,-32
    80004cfe:	ec06                	sd	ra,24(sp)
    80004d00:	e822                	sd	s0,16(sp)
    80004d02:	e426                	sd	s1,8(sp)
    80004d04:	e04a                	sd	s2,0(sp)
    80004d06:	1000                	add	s0,sp,32
    80004d08:	84aa                	mv	s1,a0
    80004d0a:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004d0c:	ffffc097          	auipc	ra,0xffffc
    80004d10:	ec6080e7          	jalr	-314(ra) # 80000bd2 <acquire>
  if(writable){
    80004d14:	02090d63          	beqz	s2,80004d4e <pipeclose+0x52>
    pi->writeopen = 0;
    80004d18:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004d1c:	21848513          	add	a0,s1,536
    80004d20:	ffffd097          	auipc	ra,0xffffd
    80004d24:	5f0080e7          	jalr	1520(ra) # 80002310 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004d28:	2204b783          	ld	a5,544(s1)
    80004d2c:	eb95                	bnez	a5,80004d60 <pipeclose+0x64>
    release(&pi->lock);
    80004d2e:	8526                	mv	a0,s1
    80004d30:	ffffc097          	auipc	ra,0xffffc
    80004d34:	f56080e7          	jalr	-170(ra) # 80000c86 <release>
    kfree((char*)pi);
    80004d38:	8526                	mv	a0,s1
    80004d3a:	ffffc097          	auipc	ra,0xffffc
    80004d3e:	caa080e7          	jalr	-854(ra) # 800009e4 <kfree>
  } else
    release(&pi->lock);
}
    80004d42:	60e2                	ld	ra,24(sp)
    80004d44:	6442                	ld	s0,16(sp)
    80004d46:	64a2                	ld	s1,8(sp)
    80004d48:	6902                	ld	s2,0(sp)
    80004d4a:	6105                	add	sp,sp,32
    80004d4c:	8082                	ret
    pi->readopen = 0;
    80004d4e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004d52:	21c48513          	add	a0,s1,540
    80004d56:	ffffd097          	auipc	ra,0xffffd
    80004d5a:	5ba080e7          	jalr	1466(ra) # 80002310 <wakeup>
    80004d5e:	b7e9                	j	80004d28 <pipeclose+0x2c>
    release(&pi->lock);
    80004d60:	8526                	mv	a0,s1
    80004d62:	ffffc097          	auipc	ra,0xffffc
    80004d66:	f24080e7          	jalr	-220(ra) # 80000c86 <release>
}
    80004d6a:	bfe1                	j	80004d42 <pipeclose+0x46>

0000000080004d6c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004d6c:	711d                	add	sp,sp,-96
    80004d6e:	ec86                	sd	ra,88(sp)
    80004d70:	e8a2                	sd	s0,80(sp)
    80004d72:	e4a6                	sd	s1,72(sp)
    80004d74:	e0ca                	sd	s2,64(sp)
    80004d76:	fc4e                	sd	s3,56(sp)
    80004d78:	f852                	sd	s4,48(sp)
    80004d7a:	f456                	sd	s5,40(sp)
    80004d7c:	f05a                	sd	s6,32(sp)
    80004d7e:	ec5e                	sd	s7,24(sp)
    80004d80:	e862                	sd	s8,16(sp)
    80004d82:	1080                	add	s0,sp,96
    80004d84:	84aa                	mv	s1,a0
    80004d86:	8aae                	mv	s5,a1
    80004d88:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004d8a:	ffffd097          	auipc	ra,0xffffd
    80004d8e:	c1c080e7          	jalr	-996(ra) # 800019a6 <myproc>
    80004d92:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004d94:	8526                	mv	a0,s1
    80004d96:	ffffc097          	auipc	ra,0xffffc
    80004d9a:	e3c080e7          	jalr	-452(ra) # 80000bd2 <acquire>
  while(i < n){
    80004d9e:	0b405663          	blez	s4,80004e4a <pipewrite+0xde>
  int i = 0;
    80004da2:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004da4:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004da6:	21848c13          	add	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004daa:	21c48b93          	add	s7,s1,540
    80004dae:	a089                	j	80004df0 <pipewrite+0x84>
      release(&pi->lock);
    80004db0:	8526                	mv	a0,s1
    80004db2:	ffffc097          	auipc	ra,0xffffc
    80004db6:	ed4080e7          	jalr	-300(ra) # 80000c86 <release>
      return -1;
    80004dba:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004dbc:	854a                	mv	a0,s2
    80004dbe:	60e6                	ld	ra,88(sp)
    80004dc0:	6446                	ld	s0,80(sp)
    80004dc2:	64a6                	ld	s1,72(sp)
    80004dc4:	6906                	ld	s2,64(sp)
    80004dc6:	79e2                	ld	s3,56(sp)
    80004dc8:	7a42                	ld	s4,48(sp)
    80004dca:	7aa2                	ld	s5,40(sp)
    80004dcc:	7b02                	ld	s6,32(sp)
    80004dce:	6be2                	ld	s7,24(sp)
    80004dd0:	6c42                	ld	s8,16(sp)
    80004dd2:	6125                	add	sp,sp,96
    80004dd4:	8082                	ret
      wakeup(&pi->nread);
    80004dd6:	8562                	mv	a0,s8
    80004dd8:	ffffd097          	auipc	ra,0xffffd
    80004ddc:	538080e7          	jalr	1336(ra) # 80002310 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004de0:	85a6                	mv	a1,s1
    80004de2:	855e                	mv	a0,s7
    80004de4:	ffffd097          	auipc	ra,0xffffd
    80004de8:	37c080e7          	jalr	892(ra) # 80002160 <sleep>
  while(i < n){
    80004dec:	07495063          	bge	s2,s4,80004e4c <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004df0:	2204a783          	lw	a5,544(s1)
    80004df4:	dfd5                	beqz	a5,80004db0 <pipewrite+0x44>
    80004df6:	854e                	mv	a0,s3
    80004df8:	ffffd097          	auipc	ra,0xffffd
    80004dfc:	768080e7          	jalr	1896(ra) # 80002560 <killed>
    80004e00:	f945                	bnez	a0,80004db0 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004e02:	2184a783          	lw	a5,536(s1)
    80004e06:	21c4a703          	lw	a4,540(s1)
    80004e0a:	2007879b          	addw	a5,a5,512
    80004e0e:	fcf704e3          	beq	a4,a5,80004dd6 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004e12:	4685                	li	a3,1
    80004e14:	01590633          	add	a2,s2,s5
    80004e18:	faf40593          	add	a1,s0,-81
    80004e1c:	0509b503          	ld	a0,80(s3)
    80004e20:	ffffd097          	auipc	ra,0xffffd
    80004e24:	8d2080e7          	jalr	-1838(ra) # 800016f2 <copyin>
    80004e28:	03650263          	beq	a0,s6,80004e4c <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004e2c:	21c4a783          	lw	a5,540(s1)
    80004e30:	0017871b          	addw	a4,a5,1
    80004e34:	20e4ae23          	sw	a4,540(s1)
    80004e38:	1ff7f793          	and	a5,a5,511
    80004e3c:	97a6                	add	a5,a5,s1
    80004e3e:	faf44703          	lbu	a4,-81(s0)
    80004e42:	00e78c23          	sb	a4,24(a5)
      i++;
    80004e46:	2905                	addw	s2,s2,1
    80004e48:	b755                	j	80004dec <pipewrite+0x80>
  int i = 0;
    80004e4a:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004e4c:	21848513          	add	a0,s1,536
    80004e50:	ffffd097          	auipc	ra,0xffffd
    80004e54:	4c0080e7          	jalr	1216(ra) # 80002310 <wakeup>
  release(&pi->lock);
    80004e58:	8526                	mv	a0,s1
    80004e5a:	ffffc097          	auipc	ra,0xffffc
    80004e5e:	e2c080e7          	jalr	-468(ra) # 80000c86 <release>
  return i;
    80004e62:	bfa9                	j	80004dbc <pipewrite+0x50>

0000000080004e64 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004e64:	715d                	add	sp,sp,-80
    80004e66:	e486                	sd	ra,72(sp)
    80004e68:	e0a2                	sd	s0,64(sp)
    80004e6a:	fc26                	sd	s1,56(sp)
    80004e6c:	f84a                	sd	s2,48(sp)
    80004e6e:	f44e                	sd	s3,40(sp)
    80004e70:	f052                	sd	s4,32(sp)
    80004e72:	ec56                	sd	s5,24(sp)
    80004e74:	e85a                	sd	s6,16(sp)
    80004e76:	0880                	add	s0,sp,80
    80004e78:	84aa                	mv	s1,a0
    80004e7a:	892e                	mv	s2,a1
    80004e7c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004e7e:	ffffd097          	auipc	ra,0xffffd
    80004e82:	b28080e7          	jalr	-1240(ra) # 800019a6 <myproc>
    80004e86:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004e88:	8526                	mv	a0,s1
    80004e8a:	ffffc097          	auipc	ra,0xffffc
    80004e8e:	d48080e7          	jalr	-696(ra) # 80000bd2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e92:	2184a703          	lw	a4,536(s1)
    80004e96:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e9a:	21848993          	add	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e9e:	02f71763          	bne	a4,a5,80004ecc <piperead+0x68>
    80004ea2:	2244a783          	lw	a5,548(s1)
    80004ea6:	c39d                	beqz	a5,80004ecc <piperead+0x68>
    if(killed(pr)){
    80004ea8:	8552                	mv	a0,s4
    80004eaa:	ffffd097          	auipc	ra,0xffffd
    80004eae:	6b6080e7          	jalr	1718(ra) # 80002560 <killed>
    80004eb2:	e949                	bnez	a0,80004f44 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004eb4:	85a6                	mv	a1,s1
    80004eb6:	854e                	mv	a0,s3
    80004eb8:	ffffd097          	auipc	ra,0xffffd
    80004ebc:	2a8080e7          	jalr	680(ra) # 80002160 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ec0:	2184a703          	lw	a4,536(s1)
    80004ec4:	21c4a783          	lw	a5,540(s1)
    80004ec8:	fcf70de3          	beq	a4,a5,80004ea2 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ecc:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004ece:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ed0:	05505463          	blez	s5,80004f18 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004ed4:	2184a783          	lw	a5,536(s1)
    80004ed8:	21c4a703          	lw	a4,540(s1)
    80004edc:	02f70e63          	beq	a4,a5,80004f18 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004ee0:	0017871b          	addw	a4,a5,1
    80004ee4:	20e4ac23          	sw	a4,536(s1)
    80004ee8:	1ff7f793          	and	a5,a5,511
    80004eec:	97a6                	add	a5,a5,s1
    80004eee:	0187c783          	lbu	a5,24(a5)
    80004ef2:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004ef6:	4685                	li	a3,1
    80004ef8:	fbf40613          	add	a2,s0,-65
    80004efc:	85ca                	mv	a1,s2
    80004efe:	050a3503          	ld	a0,80(s4)
    80004f02:	ffffc097          	auipc	ra,0xffffc
    80004f06:	764080e7          	jalr	1892(ra) # 80001666 <copyout>
    80004f0a:	01650763          	beq	a0,s6,80004f18 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f0e:	2985                	addw	s3,s3,1
    80004f10:	0905                	add	s2,s2,1
    80004f12:	fd3a91e3          	bne	s5,s3,80004ed4 <piperead+0x70>
    80004f16:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004f18:	21c48513          	add	a0,s1,540
    80004f1c:	ffffd097          	auipc	ra,0xffffd
    80004f20:	3f4080e7          	jalr	1012(ra) # 80002310 <wakeup>
  release(&pi->lock);
    80004f24:	8526                	mv	a0,s1
    80004f26:	ffffc097          	auipc	ra,0xffffc
    80004f2a:	d60080e7          	jalr	-672(ra) # 80000c86 <release>
  return i;
}
    80004f2e:	854e                	mv	a0,s3
    80004f30:	60a6                	ld	ra,72(sp)
    80004f32:	6406                	ld	s0,64(sp)
    80004f34:	74e2                	ld	s1,56(sp)
    80004f36:	7942                	ld	s2,48(sp)
    80004f38:	79a2                	ld	s3,40(sp)
    80004f3a:	7a02                	ld	s4,32(sp)
    80004f3c:	6ae2                	ld	s5,24(sp)
    80004f3e:	6b42                	ld	s6,16(sp)
    80004f40:	6161                	add	sp,sp,80
    80004f42:	8082                	ret
      release(&pi->lock);
    80004f44:	8526                	mv	a0,s1
    80004f46:	ffffc097          	auipc	ra,0xffffc
    80004f4a:	d40080e7          	jalr	-704(ra) # 80000c86 <release>
      return -1;
    80004f4e:	59fd                	li	s3,-1
    80004f50:	bff9                	j	80004f2e <piperead+0xca>

0000000080004f52 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004f52:	1141                	add	sp,sp,-16
    80004f54:	e422                	sd	s0,8(sp)
    80004f56:	0800                	add	s0,sp,16
    80004f58:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004f5a:	8905                	and	a0,a0,1
    80004f5c:	050e                	sll	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004f5e:	8b89                	and	a5,a5,2
    80004f60:	c399                	beqz	a5,80004f66 <flags2perm+0x14>
      perm |= PTE_W;
    80004f62:	00456513          	or	a0,a0,4
    return perm;
}
    80004f66:	6422                	ld	s0,8(sp)
    80004f68:	0141                	add	sp,sp,16
    80004f6a:	8082                	ret

0000000080004f6c <exec>:

int
exec(char *path, char **argv)
{
    80004f6c:	df010113          	add	sp,sp,-528
    80004f70:	20113423          	sd	ra,520(sp)
    80004f74:	20813023          	sd	s0,512(sp)
    80004f78:	ffa6                	sd	s1,504(sp)
    80004f7a:	fbca                	sd	s2,496(sp)
    80004f7c:	f7ce                	sd	s3,488(sp)
    80004f7e:	f3d2                	sd	s4,480(sp)
    80004f80:	efd6                	sd	s5,472(sp)
    80004f82:	ebda                	sd	s6,464(sp)
    80004f84:	e7de                	sd	s7,456(sp)
    80004f86:	e3e2                	sd	s8,448(sp)
    80004f88:	ff66                	sd	s9,440(sp)
    80004f8a:	fb6a                	sd	s10,432(sp)
    80004f8c:	f76e                	sd	s11,424(sp)
    80004f8e:	0c00                	add	s0,sp,528
    80004f90:	892a                	mv	s2,a0
    80004f92:	dea43c23          	sd	a0,-520(s0)
    80004f96:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004f9a:	ffffd097          	auipc	ra,0xffffd
    80004f9e:	a0c080e7          	jalr	-1524(ra) # 800019a6 <myproc>
    80004fa2:	84aa                	mv	s1,a0

  begin_op();
    80004fa4:	fffff097          	auipc	ra,0xfffff
    80004fa8:	48e080e7          	jalr	1166(ra) # 80004432 <begin_op>

  if((ip = namei(path)) == 0){
    80004fac:	854a                	mv	a0,s2
    80004fae:	fffff097          	auipc	ra,0xfffff
    80004fb2:	284080e7          	jalr	644(ra) # 80004232 <namei>
    80004fb6:	c92d                	beqz	a0,80005028 <exec+0xbc>
    80004fb8:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004fba:	fffff097          	auipc	ra,0xfffff
    80004fbe:	ad2080e7          	jalr	-1326(ra) # 80003a8c <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004fc2:	04000713          	li	a4,64
    80004fc6:	4681                	li	a3,0
    80004fc8:	e5040613          	add	a2,s0,-432
    80004fcc:	4581                	li	a1,0
    80004fce:	8552                	mv	a0,s4
    80004fd0:	fffff097          	auipc	ra,0xfffff
    80004fd4:	d70080e7          	jalr	-656(ra) # 80003d40 <readi>
    80004fd8:	04000793          	li	a5,64
    80004fdc:	00f51a63          	bne	a0,a5,80004ff0 <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004fe0:	e5042703          	lw	a4,-432(s0)
    80004fe4:	464c47b7          	lui	a5,0x464c4
    80004fe8:	57f78793          	add	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004fec:	04f70463          	beq	a4,a5,80005034 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004ff0:	8552                	mv	a0,s4
    80004ff2:	fffff097          	auipc	ra,0xfffff
    80004ff6:	cfc080e7          	jalr	-772(ra) # 80003cee <iunlockput>
    end_op();
    80004ffa:	fffff097          	auipc	ra,0xfffff
    80004ffe:	4b2080e7          	jalr	1202(ra) # 800044ac <end_op>
  }
  return -1;
    80005002:	557d                	li	a0,-1
}
    80005004:	20813083          	ld	ra,520(sp)
    80005008:	20013403          	ld	s0,512(sp)
    8000500c:	74fe                	ld	s1,504(sp)
    8000500e:	795e                	ld	s2,496(sp)
    80005010:	79be                	ld	s3,488(sp)
    80005012:	7a1e                	ld	s4,480(sp)
    80005014:	6afe                	ld	s5,472(sp)
    80005016:	6b5e                	ld	s6,464(sp)
    80005018:	6bbe                	ld	s7,456(sp)
    8000501a:	6c1e                	ld	s8,448(sp)
    8000501c:	7cfa                	ld	s9,440(sp)
    8000501e:	7d5a                	ld	s10,432(sp)
    80005020:	7dba                	ld	s11,424(sp)
    80005022:	21010113          	add	sp,sp,528
    80005026:	8082                	ret
    end_op();
    80005028:	fffff097          	auipc	ra,0xfffff
    8000502c:	484080e7          	jalr	1156(ra) # 800044ac <end_op>
    return -1;
    80005030:	557d                	li	a0,-1
    80005032:	bfc9                	j	80005004 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80005034:	8526                	mv	a0,s1
    80005036:	ffffd097          	auipc	ra,0xffffd
    8000503a:	a34080e7          	jalr	-1484(ra) # 80001a6a <proc_pagetable>
    8000503e:	8b2a                	mv	s6,a0
    80005040:	d945                	beqz	a0,80004ff0 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005042:	e7042d03          	lw	s10,-400(s0)
    80005046:	e8845783          	lhu	a5,-376(s0)
    8000504a:	10078463          	beqz	a5,80005152 <exec+0x1e6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000504e:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005050:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80005052:	6c85                	lui	s9,0x1
    80005054:	fffc8793          	add	a5,s9,-1 # fff <_entry-0x7ffff001>
    80005058:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    8000505c:	6a85                	lui	s5,0x1
    8000505e:	a0b5                	j	800050ca <exec+0x15e>
      panic("loadseg: address should exist");
    80005060:	00003517          	auipc	a0,0x3
    80005064:	7e050513          	add	a0,a0,2016 # 80008840 <syscalls+0x290>
    80005068:	ffffb097          	auipc	ra,0xffffb
    8000506c:	4d4080e7          	jalr	1236(ra) # 8000053c <panic>
    if(sz - i < PGSIZE)
    80005070:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005072:	8726                	mv	a4,s1
    80005074:	012c06bb          	addw	a3,s8,s2
    80005078:	4581                	li	a1,0
    8000507a:	8552                	mv	a0,s4
    8000507c:	fffff097          	auipc	ra,0xfffff
    80005080:	cc4080e7          	jalr	-828(ra) # 80003d40 <readi>
    80005084:	2501                	sext.w	a0,a0
    80005086:	24a49863          	bne	s1,a0,800052d6 <exec+0x36a>
  for(i = 0; i < sz; i += PGSIZE){
    8000508a:	012a893b          	addw	s2,s5,s2
    8000508e:	03397563          	bgeu	s2,s3,800050b8 <exec+0x14c>
    pa = walkaddr(pagetable, va + i);
    80005092:	02091593          	sll	a1,s2,0x20
    80005096:	9181                	srl	a1,a1,0x20
    80005098:	95de                	add	a1,a1,s7
    8000509a:	855a                	mv	a0,s6
    8000509c:	ffffc097          	auipc	ra,0xffffc
    800050a0:	fba080e7          	jalr	-70(ra) # 80001056 <walkaddr>
    800050a4:	862a                	mv	a2,a0
    if(pa == 0)
    800050a6:	dd4d                	beqz	a0,80005060 <exec+0xf4>
    if(sz - i < PGSIZE)
    800050a8:	412984bb          	subw	s1,s3,s2
    800050ac:	0004879b          	sext.w	a5,s1
    800050b0:	fcfcf0e3          	bgeu	s9,a5,80005070 <exec+0x104>
    800050b4:	84d6                	mv	s1,s5
    800050b6:	bf6d                	j	80005070 <exec+0x104>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800050b8:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800050bc:	2d85                	addw	s11,s11,1
    800050be:	038d0d1b          	addw	s10,s10,56
    800050c2:	e8845783          	lhu	a5,-376(s0)
    800050c6:	08fdd763          	bge	s11,a5,80005154 <exec+0x1e8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800050ca:	2d01                	sext.w	s10,s10
    800050cc:	03800713          	li	a4,56
    800050d0:	86ea                	mv	a3,s10
    800050d2:	e1840613          	add	a2,s0,-488
    800050d6:	4581                	li	a1,0
    800050d8:	8552                	mv	a0,s4
    800050da:	fffff097          	auipc	ra,0xfffff
    800050de:	c66080e7          	jalr	-922(ra) # 80003d40 <readi>
    800050e2:	03800793          	li	a5,56
    800050e6:	1ef51663          	bne	a0,a5,800052d2 <exec+0x366>
    if(ph.type != ELF_PROG_LOAD)
    800050ea:	e1842783          	lw	a5,-488(s0)
    800050ee:	4705                	li	a4,1
    800050f0:	fce796e3          	bne	a5,a4,800050bc <exec+0x150>
    if(ph.memsz < ph.filesz)
    800050f4:	e4043483          	ld	s1,-448(s0)
    800050f8:	e3843783          	ld	a5,-456(s0)
    800050fc:	1ef4e863          	bltu	s1,a5,800052ec <exec+0x380>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005100:	e2843783          	ld	a5,-472(s0)
    80005104:	94be                	add	s1,s1,a5
    80005106:	1ef4e663          	bltu	s1,a5,800052f2 <exec+0x386>
    if(ph.vaddr % PGSIZE != 0)
    8000510a:	df043703          	ld	a4,-528(s0)
    8000510e:	8ff9                	and	a5,a5,a4
    80005110:	1e079463          	bnez	a5,800052f8 <exec+0x38c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005114:	e1c42503          	lw	a0,-484(s0)
    80005118:	00000097          	auipc	ra,0x0
    8000511c:	e3a080e7          	jalr	-454(ra) # 80004f52 <flags2perm>
    80005120:	86aa                	mv	a3,a0
    80005122:	8626                	mv	a2,s1
    80005124:	85ca                	mv	a1,s2
    80005126:	855a                	mv	a0,s6
    80005128:	ffffc097          	auipc	ra,0xffffc
    8000512c:	2e2080e7          	jalr	738(ra) # 8000140a <uvmalloc>
    80005130:	e0a43423          	sd	a0,-504(s0)
    80005134:	1c050563          	beqz	a0,800052fe <exec+0x392>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005138:	e2843b83          	ld	s7,-472(s0)
    8000513c:	e2042c03          	lw	s8,-480(s0)
    80005140:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005144:	00098463          	beqz	s3,8000514c <exec+0x1e0>
    80005148:	4901                	li	s2,0
    8000514a:	b7a1                	j	80005092 <exec+0x126>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000514c:	e0843903          	ld	s2,-504(s0)
    80005150:	b7b5                	j	800050bc <exec+0x150>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005152:	4901                	li	s2,0
  iunlockput(ip);
    80005154:	8552                	mv	a0,s4
    80005156:	fffff097          	auipc	ra,0xfffff
    8000515a:	b98080e7          	jalr	-1128(ra) # 80003cee <iunlockput>
  end_op();
    8000515e:	fffff097          	auipc	ra,0xfffff
    80005162:	34e080e7          	jalr	846(ra) # 800044ac <end_op>
  p = myproc();
    80005166:	ffffd097          	auipc	ra,0xffffd
    8000516a:	840080e7          	jalr	-1984(ra) # 800019a6 <myproc>
    8000516e:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005170:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80005174:	6985                	lui	s3,0x1
    80005176:	19fd                	add	s3,s3,-1 # fff <_entry-0x7ffff001>
    80005178:	99ca                	add	s3,s3,s2
    8000517a:	77fd                	lui	a5,0xfffff
    8000517c:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005180:	4691                	li	a3,4
    80005182:	6609                	lui	a2,0x2
    80005184:	964e                	add	a2,a2,s3
    80005186:	85ce                	mv	a1,s3
    80005188:	855a                	mv	a0,s6
    8000518a:	ffffc097          	auipc	ra,0xffffc
    8000518e:	280080e7          	jalr	640(ra) # 8000140a <uvmalloc>
    80005192:	892a                	mv	s2,a0
    80005194:	e0a43423          	sd	a0,-504(s0)
    80005198:	e509                	bnez	a0,800051a2 <exec+0x236>
  if(pagetable)
    8000519a:	e1343423          	sd	s3,-504(s0)
    8000519e:	4a01                	li	s4,0
    800051a0:	aa1d                	j	800052d6 <exec+0x36a>
  uvmclear(pagetable, sz-2*PGSIZE);
    800051a2:	75f9                	lui	a1,0xffffe
    800051a4:	95aa                	add	a1,a1,a0
    800051a6:	855a                	mv	a0,s6
    800051a8:	ffffc097          	auipc	ra,0xffffc
    800051ac:	48c080e7          	jalr	1164(ra) # 80001634 <uvmclear>
  stackbase = sp - PGSIZE;
    800051b0:	7bfd                	lui	s7,0xfffff
    800051b2:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    800051b4:	e0043783          	ld	a5,-512(s0)
    800051b8:	6388                	ld	a0,0(a5)
    800051ba:	c52d                	beqz	a0,80005224 <exec+0x2b8>
    800051bc:	e9040993          	add	s3,s0,-368
    800051c0:	f9040c13          	add	s8,s0,-112
    800051c4:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800051c6:	ffffc097          	auipc	ra,0xffffc
    800051ca:	c82080e7          	jalr	-894(ra) # 80000e48 <strlen>
    800051ce:	0015079b          	addw	a5,a0,1
    800051d2:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800051d6:	ff07f913          	and	s2,a5,-16
    if(sp < stackbase)
    800051da:	13796563          	bltu	s2,s7,80005304 <exec+0x398>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800051de:	e0043d03          	ld	s10,-512(s0)
    800051e2:	000d3a03          	ld	s4,0(s10)
    800051e6:	8552                	mv	a0,s4
    800051e8:	ffffc097          	auipc	ra,0xffffc
    800051ec:	c60080e7          	jalr	-928(ra) # 80000e48 <strlen>
    800051f0:	0015069b          	addw	a3,a0,1
    800051f4:	8652                	mv	a2,s4
    800051f6:	85ca                	mv	a1,s2
    800051f8:	855a                	mv	a0,s6
    800051fa:	ffffc097          	auipc	ra,0xffffc
    800051fe:	46c080e7          	jalr	1132(ra) # 80001666 <copyout>
    80005202:	10054363          	bltz	a0,80005308 <exec+0x39c>
    ustack[argc] = sp;
    80005206:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000520a:	0485                	add	s1,s1,1
    8000520c:	008d0793          	add	a5,s10,8
    80005210:	e0f43023          	sd	a5,-512(s0)
    80005214:	008d3503          	ld	a0,8(s10)
    80005218:	c909                	beqz	a0,8000522a <exec+0x2be>
    if(argc >= MAXARG)
    8000521a:	09a1                	add	s3,s3,8
    8000521c:	fb8995e3          	bne	s3,s8,800051c6 <exec+0x25a>
  ip = 0;
    80005220:	4a01                	li	s4,0
    80005222:	a855                	j	800052d6 <exec+0x36a>
  sp = sz;
    80005224:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80005228:	4481                	li	s1,0
  ustack[argc] = 0;
    8000522a:	00349793          	sll	a5,s1,0x3
    8000522e:	f9078793          	add	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdc7b0>
    80005232:	97a2                	add	a5,a5,s0
    80005234:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005238:	00148693          	add	a3,s1,1
    8000523c:	068e                	sll	a3,a3,0x3
    8000523e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005242:	ff097913          	and	s2,s2,-16
  sz = sz1;
    80005246:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    8000524a:	f57968e3          	bltu	s2,s7,8000519a <exec+0x22e>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000524e:	e9040613          	add	a2,s0,-368
    80005252:	85ca                	mv	a1,s2
    80005254:	855a                	mv	a0,s6
    80005256:	ffffc097          	auipc	ra,0xffffc
    8000525a:	410080e7          	jalr	1040(ra) # 80001666 <copyout>
    8000525e:	0a054763          	bltz	a0,8000530c <exec+0x3a0>
  p->trapframe->a1 = sp;
    80005262:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80005266:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000526a:	df843783          	ld	a5,-520(s0)
    8000526e:	0007c703          	lbu	a4,0(a5)
    80005272:	cf11                	beqz	a4,8000528e <exec+0x322>
    80005274:	0785                	add	a5,a5,1
    if(*s == '/')
    80005276:	02f00693          	li	a3,47
    8000527a:	a039                	j	80005288 <exec+0x31c>
      last = s+1;
    8000527c:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80005280:	0785                	add	a5,a5,1
    80005282:	fff7c703          	lbu	a4,-1(a5)
    80005286:	c701                	beqz	a4,8000528e <exec+0x322>
    if(*s == '/')
    80005288:	fed71ce3          	bne	a4,a3,80005280 <exec+0x314>
    8000528c:	bfc5                	j	8000527c <exec+0x310>
  safestrcpy(p->name, last, sizeof(p->name));
    8000528e:	4641                	li	a2,16
    80005290:	df843583          	ld	a1,-520(s0)
    80005294:	158a8513          	add	a0,s5,344
    80005298:	ffffc097          	auipc	ra,0xffffc
    8000529c:	b7e080e7          	jalr	-1154(ra) # 80000e16 <safestrcpy>
  oldpagetable = p->pagetable;
    800052a0:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800052a4:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800052a8:	e0843783          	ld	a5,-504(s0)
    800052ac:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800052b0:	058ab783          	ld	a5,88(s5)
    800052b4:	e6843703          	ld	a4,-408(s0)
    800052b8:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800052ba:	058ab783          	ld	a5,88(s5)
    800052be:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800052c2:	85e6                	mv	a1,s9
    800052c4:	ffffd097          	auipc	ra,0xffffd
    800052c8:	842080e7          	jalr	-1982(ra) # 80001b06 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800052cc:	0004851b          	sext.w	a0,s1
    800052d0:	bb15                	j	80005004 <exec+0x98>
    800052d2:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    800052d6:	e0843583          	ld	a1,-504(s0)
    800052da:	855a                	mv	a0,s6
    800052dc:	ffffd097          	auipc	ra,0xffffd
    800052e0:	82a080e7          	jalr	-2006(ra) # 80001b06 <proc_freepagetable>
  return -1;
    800052e4:	557d                	li	a0,-1
  if(ip){
    800052e6:	d00a0fe3          	beqz	s4,80005004 <exec+0x98>
    800052ea:	b319                	j	80004ff0 <exec+0x84>
    800052ec:	e1243423          	sd	s2,-504(s0)
    800052f0:	b7dd                	j	800052d6 <exec+0x36a>
    800052f2:	e1243423          	sd	s2,-504(s0)
    800052f6:	b7c5                	j	800052d6 <exec+0x36a>
    800052f8:	e1243423          	sd	s2,-504(s0)
    800052fc:	bfe9                	j	800052d6 <exec+0x36a>
    800052fe:	e1243423          	sd	s2,-504(s0)
    80005302:	bfd1                	j	800052d6 <exec+0x36a>
  ip = 0;
    80005304:	4a01                	li	s4,0
    80005306:	bfc1                	j	800052d6 <exec+0x36a>
    80005308:	4a01                	li	s4,0
  if(pagetable)
    8000530a:	b7f1                	j	800052d6 <exec+0x36a>
  sz = sz1;
    8000530c:	e0843983          	ld	s3,-504(s0)
    80005310:	b569                	j	8000519a <exec+0x22e>

0000000080005312 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005312:	7179                	add	sp,sp,-48
    80005314:	f406                	sd	ra,40(sp)
    80005316:	f022                	sd	s0,32(sp)
    80005318:	ec26                	sd	s1,24(sp)
    8000531a:	e84a                	sd	s2,16(sp)
    8000531c:	1800                	add	s0,sp,48
    8000531e:	892e                	mv	s2,a1
    80005320:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005322:	fdc40593          	add	a1,s0,-36
    80005326:	ffffe097          	auipc	ra,0xffffe
    8000532a:	9f4080e7          	jalr	-1548(ra) # 80002d1a <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000532e:	fdc42703          	lw	a4,-36(s0)
    80005332:	47bd                	li	a5,15
    80005334:	02e7eb63          	bltu	a5,a4,8000536a <argfd+0x58>
    80005338:	ffffc097          	auipc	ra,0xffffc
    8000533c:	66e080e7          	jalr	1646(ra) # 800019a6 <myproc>
    80005340:	fdc42703          	lw	a4,-36(s0)
    80005344:	01a70793          	add	a5,a4,26
    80005348:	078e                	sll	a5,a5,0x3
    8000534a:	953e                	add	a0,a0,a5
    8000534c:	611c                	ld	a5,0(a0)
    8000534e:	c385                	beqz	a5,8000536e <argfd+0x5c>
    return -1;
  if(pfd)
    80005350:	00090463          	beqz	s2,80005358 <argfd+0x46>
    *pfd = fd;
    80005354:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005358:	4501                	li	a0,0
  if(pf)
    8000535a:	c091                	beqz	s1,8000535e <argfd+0x4c>
    *pf = f;
    8000535c:	e09c                	sd	a5,0(s1)
}
    8000535e:	70a2                	ld	ra,40(sp)
    80005360:	7402                	ld	s0,32(sp)
    80005362:	64e2                	ld	s1,24(sp)
    80005364:	6942                	ld	s2,16(sp)
    80005366:	6145                	add	sp,sp,48
    80005368:	8082                	ret
    return -1;
    8000536a:	557d                	li	a0,-1
    8000536c:	bfcd                	j	8000535e <argfd+0x4c>
    8000536e:	557d                	li	a0,-1
    80005370:	b7fd                	j	8000535e <argfd+0x4c>

0000000080005372 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005372:	1101                	add	sp,sp,-32
    80005374:	ec06                	sd	ra,24(sp)
    80005376:	e822                	sd	s0,16(sp)
    80005378:	e426                	sd	s1,8(sp)
    8000537a:	1000                	add	s0,sp,32
    8000537c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000537e:	ffffc097          	auipc	ra,0xffffc
    80005382:	628080e7          	jalr	1576(ra) # 800019a6 <myproc>
    80005386:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005388:	0d050793          	add	a5,a0,208
    8000538c:	4501                	li	a0,0
    8000538e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005390:	6398                	ld	a4,0(a5)
    80005392:	cb19                	beqz	a4,800053a8 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005394:	2505                	addw	a0,a0,1
    80005396:	07a1                	add	a5,a5,8
    80005398:	fed51ce3          	bne	a0,a3,80005390 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000539c:	557d                	li	a0,-1
}
    8000539e:	60e2                	ld	ra,24(sp)
    800053a0:	6442                	ld	s0,16(sp)
    800053a2:	64a2                	ld	s1,8(sp)
    800053a4:	6105                	add	sp,sp,32
    800053a6:	8082                	ret
      p->ofile[fd] = f;
    800053a8:	01a50793          	add	a5,a0,26
    800053ac:	078e                	sll	a5,a5,0x3
    800053ae:	963e                	add	a2,a2,a5
    800053b0:	e204                	sd	s1,0(a2)
      return fd;
    800053b2:	b7f5                	j	8000539e <fdalloc+0x2c>

00000000800053b4 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800053b4:	715d                	add	sp,sp,-80
    800053b6:	e486                	sd	ra,72(sp)
    800053b8:	e0a2                	sd	s0,64(sp)
    800053ba:	fc26                	sd	s1,56(sp)
    800053bc:	f84a                	sd	s2,48(sp)
    800053be:	f44e                	sd	s3,40(sp)
    800053c0:	f052                	sd	s4,32(sp)
    800053c2:	ec56                	sd	s5,24(sp)
    800053c4:	e85a                	sd	s6,16(sp)
    800053c6:	0880                	add	s0,sp,80
    800053c8:	8b2e                	mv	s6,a1
    800053ca:	89b2                	mv	s3,a2
    800053cc:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800053ce:	fb040593          	add	a1,s0,-80
    800053d2:	fffff097          	auipc	ra,0xfffff
    800053d6:	e7e080e7          	jalr	-386(ra) # 80004250 <nameiparent>
    800053da:	84aa                	mv	s1,a0
    800053dc:	14050b63          	beqz	a0,80005532 <create+0x17e>
    return 0;

  ilock(dp);
    800053e0:	ffffe097          	auipc	ra,0xffffe
    800053e4:	6ac080e7          	jalr	1708(ra) # 80003a8c <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800053e8:	4601                	li	a2,0
    800053ea:	fb040593          	add	a1,s0,-80
    800053ee:	8526                	mv	a0,s1
    800053f0:	fffff097          	auipc	ra,0xfffff
    800053f4:	b80080e7          	jalr	-1152(ra) # 80003f70 <dirlookup>
    800053f8:	8aaa                	mv	s5,a0
    800053fa:	c921                	beqz	a0,8000544a <create+0x96>
    iunlockput(dp);
    800053fc:	8526                	mv	a0,s1
    800053fe:	fffff097          	auipc	ra,0xfffff
    80005402:	8f0080e7          	jalr	-1808(ra) # 80003cee <iunlockput>
    ilock(ip);
    80005406:	8556                	mv	a0,s5
    80005408:	ffffe097          	auipc	ra,0xffffe
    8000540c:	684080e7          	jalr	1668(ra) # 80003a8c <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005410:	4789                	li	a5,2
    80005412:	02fb1563          	bne	s6,a5,8000543c <create+0x88>
    80005416:	044ad783          	lhu	a5,68(s5)
    8000541a:	37f9                	addw	a5,a5,-2
    8000541c:	17c2                	sll	a5,a5,0x30
    8000541e:	93c1                	srl	a5,a5,0x30
    80005420:	4705                	li	a4,1
    80005422:	00f76d63          	bltu	a4,a5,8000543c <create+0x88>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005426:	8556                	mv	a0,s5
    80005428:	60a6                	ld	ra,72(sp)
    8000542a:	6406                	ld	s0,64(sp)
    8000542c:	74e2                	ld	s1,56(sp)
    8000542e:	7942                	ld	s2,48(sp)
    80005430:	79a2                	ld	s3,40(sp)
    80005432:	7a02                	ld	s4,32(sp)
    80005434:	6ae2                	ld	s5,24(sp)
    80005436:	6b42                	ld	s6,16(sp)
    80005438:	6161                	add	sp,sp,80
    8000543a:	8082                	ret
    iunlockput(ip);
    8000543c:	8556                	mv	a0,s5
    8000543e:	fffff097          	auipc	ra,0xfffff
    80005442:	8b0080e7          	jalr	-1872(ra) # 80003cee <iunlockput>
    return 0;
    80005446:	4a81                	li	s5,0
    80005448:	bff9                	j	80005426 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000544a:	85da                	mv	a1,s6
    8000544c:	4088                	lw	a0,0(s1)
    8000544e:	ffffe097          	auipc	ra,0xffffe
    80005452:	4a6080e7          	jalr	1190(ra) # 800038f4 <ialloc>
    80005456:	8a2a                	mv	s4,a0
    80005458:	c529                	beqz	a0,800054a2 <create+0xee>
  ilock(ip);
    8000545a:	ffffe097          	auipc	ra,0xffffe
    8000545e:	632080e7          	jalr	1586(ra) # 80003a8c <ilock>
  ip->major = major;
    80005462:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005466:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000546a:	4905                	li	s2,1
    8000546c:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005470:	8552                	mv	a0,s4
    80005472:	ffffe097          	auipc	ra,0xffffe
    80005476:	54e080e7          	jalr	1358(ra) # 800039c0 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000547a:	032b0b63          	beq	s6,s2,800054b0 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    8000547e:	004a2603          	lw	a2,4(s4)
    80005482:	fb040593          	add	a1,s0,-80
    80005486:	8526                	mv	a0,s1
    80005488:	fffff097          	auipc	ra,0xfffff
    8000548c:	cf8080e7          	jalr	-776(ra) # 80004180 <dirlink>
    80005490:	06054f63          	bltz	a0,8000550e <create+0x15a>
  iunlockput(dp);
    80005494:	8526                	mv	a0,s1
    80005496:	fffff097          	auipc	ra,0xfffff
    8000549a:	858080e7          	jalr	-1960(ra) # 80003cee <iunlockput>
  return ip;
    8000549e:	8ad2                	mv	s5,s4
    800054a0:	b759                	j	80005426 <create+0x72>
    iunlockput(dp);
    800054a2:	8526                	mv	a0,s1
    800054a4:	fffff097          	auipc	ra,0xfffff
    800054a8:	84a080e7          	jalr	-1974(ra) # 80003cee <iunlockput>
    return 0;
    800054ac:	8ad2                	mv	s5,s4
    800054ae:	bfa5                	j	80005426 <create+0x72>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800054b0:	004a2603          	lw	a2,4(s4)
    800054b4:	00003597          	auipc	a1,0x3
    800054b8:	3ac58593          	add	a1,a1,940 # 80008860 <syscalls+0x2b0>
    800054bc:	8552                	mv	a0,s4
    800054be:	fffff097          	auipc	ra,0xfffff
    800054c2:	cc2080e7          	jalr	-830(ra) # 80004180 <dirlink>
    800054c6:	04054463          	bltz	a0,8000550e <create+0x15a>
    800054ca:	40d0                	lw	a2,4(s1)
    800054cc:	00003597          	auipc	a1,0x3
    800054d0:	39c58593          	add	a1,a1,924 # 80008868 <syscalls+0x2b8>
    800054d4:	8552                	mv	a0,s4
    800054d6:	fffff097          	auipc	ra,0xfffff
    800054da:	caa080e7          	jalr	-854(ra) # 80004180 <dirlink>
    800054de:	02054863          	bltz	a0,8000550e <create+0x15a>
  if(dirlink(dp, name, ip->inum) < 0)
    800054e2:	004a2603          	lw	a2,4(s4)
    800054e6:	fb040593          	add	a1,s0,-80
    800054ea:	8526                	mv	a0,s1
    800054ec:	fffff097          	auipc	ra,0xfffff
    800054f0:	c94080e7          	jalr	-876(ra) # 80004180 <dirlink>
    800054f4:	00054d63          	bltz	a0,8000550e <create+0x15a>
    dp->nlink++;  // for ".."
    800054f8:	04a4d783          	lhu	a5,74(s1)
    800054fc:	2785                	addw	a5,a5,1
    800054fe:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005502:	8526                	mv	a0,s1
    80005504:	ffffe097          	auipc	ra,0xffffe
    80005508:	4bc080e7          	jalr	1212(ra) # 800039c0 <iupdate>
    8000550c:	b761                	j	80005494 <create+0xe0>
  ip->nlink = 0;
    8000550e:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005512:	8552                	mv	a0,s4
    80005514:	ffffe097          	auipc	ra,0xffffe
    80005518:	4ac080e7          	jalr	1196(ra) # 800039c0 <iupdate>
  iunlockput(ip);
    8000551c:	8552                	mv	a0,s4
    8000551e:	ffffe097          	auipc	ra,0xffffe
    80005522:	7d0080e7          	jalr	2000(ra) # 80003cee <iunlockput>
  iunlockput(dp);
    80005526:	8526                	mv	a0,s1
    80005528:	ffffe097          	auipc	ra,0xffffe
    8000552c:	7c6080e7          	jalr	1990(ra) # 80003cee <iunlockput>
  return 0;
    80005530:	bddd                	j	80005426 <create+0x72>
    return 0;
    80005532:	8aaa                	mv	s5,a0
    80005534:	bdcd                	j	80005426 <create+0x72>

0000000080005536 <sys_dup>:
{
    80005536:	7179                	add	sp,sp,-48
    80005538:	f406                	sd	ra,40(sp)
    8000553a:	f022                	sd	s0,32(sp)
    8000553c:	ec26                	sd	s1,24(sp)
    8000553e:	e84a                	sd	s2,16(sp)
    80005540:	1800                	add	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005542:	fd840613          	add	a2,s0,-40
    80005546:	4581                	li	a1,0
    80005548:	4501                	li	a0,0
    8000554a:	00000097          	auipc	ra,0x0
    8000554e:	dc8080e7          	jalr	-568(ra) # 80005312 <argfd>
    return -1;
    80005552:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005554:	02054363          	bltz	a0,8000557a <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80005558:	fd843903          	ld	s2,-40(s0)
    8000555c:	854a                	mv	a0,s2
    8000555e:	00000097          	auipc	ra,0x0
    80005562:	e14080e7          	jalr	-492(ra) # 80005372 <fdalloc>
    80005566:	84aa                	mv	s1,a0
    return -1;
    80005568:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000556a:	00054863          	bltz	a0,8000557a <sys_dup+0x44>
  filedup(f);
    8000556e:	854a                	mv	a0,s2
    80005570:	fffff097          	auipc	ra,0xfffff
    80005574:	334080e7          	jalr	820(ra) # 800048a4 <filedup>
  return fd;
    80005578:	87a6                	mv	a5,s1
}
    8000557a:	853e                	mv	a0,a5
    8000557c:	70a2                	ld	ra,40(sp)
    8000557e:	7402                	ld	s0,32(sp)
    80005580:	64e2                	ld	s1,24(sp)
    80005582:	6942                	ld	s2,16(sp)
    80005584:	6145                	add	sp,sp,48
    80005586:	8082                	ret

0000000080005588 <sys_read>:
{
    80005588:	7179                	add	sp,sp,-48
    8000558a:	f406                	sd	ra,40(sp)
    8000558c:	f022                	sd	s0,32(sp)
    8000558e:	1800                	add	s0,sp,48
  argaddr(1, &p);
    80005590:	fd840593          	add	a1,s0,-40
    80005594:	4505                	li	a0,1
    80005596:	ffffd097          	auipc	ra,0xffffd
    8000559a:	7a6080e7          	jalr	1958(ra) # 80002d3c <argaddr>
  argint(2, &n);
    8000559e:	fe440593          	add	a1,s0,-28
    800055a2:	4509                	li	a0,2
    800055a4:	ffffd097          	auipc	ra,0xffffd
    800055a8:	776080e7          	jalr	1910(ra) # 80002d1a <argint>
  if(argfd(0, 0, &f) < 0)
    800055ac:	fe840613          	add	a2,s0,-24
    800055b0:	4581                	li	a1,0
    800055b2:	4501                	li	a0,0
    800055b4:	00000097          	auipc	ra,0x0
    800055b8:	d5e080e7          	jalr	-674(ra) # 80005312 <argfd>
    800055bc:	87aa                	mv	a5,a0
    return -1;
    800055be:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800055c0:	0007cc63          	bltz	a5,800055d8 <sys_read+0x50>
  return fileread(f, p, n);
    800055c4:	fe442603          	lw	a2,-28(s0)
    800055c8:	fd843583          	ld	a1,-40(s0)
    800055cc:	fe843503          	ld	a0,-24(s0)
    800055d0:	fffff097          	auipc	ra,0xfffff
    800055d4:	460080e7          	jalr	1120(ra) # 80004a30 <fileread>
}
    800055d8:	70a2                	ld	ra,40(sp)
    800055da:	7402                	ld	s0,32(sp)
    800055dc:	6145                	add	sp,sp,48
    800055de:	8082                	ret

00000000800055e0 <sys_write>:
{
    800055e0:	7179                	add	sp,sp,-48
    800055e2:	f406                	sd	ra,40(sp)
    800055e4:	f022                	sd	s0,32(sp)
    800055e6:	1800                	add	s0,sp,48
  argaddr(1, &p);
    800055e8:	fd840593          	add	a1,s0,-40
    800055ec:	4505                	li	a0,1
    800055ee:	ffffd097          	auipc	ra,0xffffd
    800055f2:	74e080e7          	jalr	1870(ra) # 80002d3c <argaddr>
  argint(2, &n);
    800055f6:	fe440593          	add	a1,s0,-28
    800055fa:	4509                	li	a0,2
    800055fc:	ffffd097          	auipc	ra,0xffffd
    80005600:	71e080e7          	jalr	1822(ra) # 80002d1a <argint>
  if(argfd(0, 0, &f) < 0)
    80005604:	fe840613          	add	a2,s0,-24
    80005608:	4581                	li	a1,0
    8000560a:	4501                	li	a0,0
    8000560c:	00000097          	auipc	ra,0x0
    80005610:	d06080e7          	jalr	-762(ra) # 80005312 <argfd>
    80005614:	87aa                	mv	a5,a0
    return -1;
    80005616:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005618:	0007cc63          	bltz	a5,80005630 <sys_write+0x50>
  return filewrite(f, p, n);
    8000561c:	fe442603          	lw	a2,-28(s0)
    80005620:	fd843583          	ld	a1,-40(s0)
    80005624:	fe843503          	ld	a0,-24(s0)
    80005628:	fffff097          	auipc	ra,0xfffff
    8000562c:	4ca080e7          	jalr	1226(ra) # 80004af2 <filewrite>
}
    80005630:	70a2                	ld	ra,40(sp)
    80005632:	7402                	ld	s0,32(sp)
    80005634:	6145                	add	sp,sp,48
    80005636:	8082                	ret

0000000080005638 <sys_close>:
{
    80005638:	1101                	add	sp,sp,-32
    8000563a:	ec06                	sd	ra,24(sp)
    8000563c:	e822                	sd	s0,16(sp)
    8000563e:	1000                	add	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005640:	fe040613          	add	a2,s0,-32
    80005644:	fec40593          	add	a1,s0,-20
    80005648:	4501                	li	a0,0
    8000564a:	00000097          	auipc	ra,0x0
    8000564e:	cc8080e7          	jalr	-824(ra) # 80005312 <argfd>
    return -1;
    80005652:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005654:	02054463          	bltz	a0,8000567c <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005658:	ffffc097          	auipc	ra,0xffffc
    8000565c:	34e080e7          	jalr	846(ra) # 800019a6 <myproc>
    80005660:	fec42783          	lw	a5,-20(s0)
    80005664:	07e9                	add	a5,a5,26
    80005666:	078e                	sll	a5,a5,0x3
    80005668:	953e                	add	a0,a0,a5
    8000566a:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000566e:	fe043503          	ld	a0,-32(s0)
    80005672:	fffff097          	auipc	ra,0xfffff
    80005676:	284080e7          	jalr	644(ra) # 800048f6 <fileclose>
  return 0;
    8000567a:	4781                	li	a5,0
}
    8000567c:	853e                	mv	a0,a5
    8000567e:	60e2                	ld	ra,24(sp)
    80005680:	6442                	ld	s0,16(sp)
    80005682:	6105                	add	sp,sp,32
    80005684:	8082                	ret

0000000080005686 <sys_fstat>:
{
    80005686:	1101                	add	sp,sp,-32
    80005688:	ec06                	sd	ra,24(sp)
    8000568a:	e822                	sd	s0,16(sp)
    8000568c:	1000                	add	s0,sp,32
  argaddr(1, &st);
    8000568e:	fe040593          	add	a1,s0,-32
    80005692:	4505                	li	a0,1
    80005694:	ffffd097          	auipc	ra,0xffffd
    80005698:	6a8080e7          	jalr	1704(ra) # 80002d3c <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000569c:	fe840613          	add	a2,s0,-24
    800056a0:	4581                	li	a1,0
    800056a2:	4501                	li	a0,0
    800056a4:	00000097          	auipc	ra,0x0
    800056a8:	c6e080e7          	jalr	-914(ra) # 80005312 <argfd>
    800056ac:	87aa                	mv	a5,a0
    return -1;
    800056ae:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800056b0:	0007ca63          	bltz	a5,800056c4 <sys_fstat+0x3e>
  return filestat(f, st);
    800056b4:	fe043583          	ld	a1,-32(s0)
    800056b8:	fe843503          	ld	a0,-24(s0)
    800056bc:	fffff097          	auipc	ra,0xfffff
    800056c0:	302080e7          	jalr	770(ra) # 800049be <filestat>
}
    800056c4:	60e2                	ld	ra,24(sp)
    800056c6:	6442                	ld	s0,16(sp)
    800056c8:	6105                	add	sp,sp,32
    800056ca:	8082                	ret

00000000800056cc <sys_link>:
{
    800056cc:	7169                	add	sp,sp,-304
    800056ce:	f606                	sd	ra,296(sp)
    800056d0:	f222                	sd	s0,288(sp)
    800056d2:	ee26                	sd	s1,280(sp)
    800056d4:	ea4a                	sd	s2,272(sp)
    800056d6:	1a00                	add	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800056d8:	08000613          	li	a2,128
    800056dc:	ed040593          	add	a1,s0,-304
    800056e0:	4501                	li	a0,0
    800056e2:	ffffd097          	auipc	ra,0xffffd
    800056e6:	67c080e7          	jalr	1660(ra) # 80002d5e <argstr>
    return -1;
    800056ea:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800056ec:	10054e63          	bltz	a0,80005808 <sys_link+0x13c>
    800056f0:	08000613          	li	a2,128
    800056f4:	f5040593          	add	a1,s0,-176
    800056f8:	4505                	li	a0,1
    800056fa:	ffffd097          	auipc	ra,0xffffd
    800056fe:	664080e7          	jalr	1636(ra) # 80002d5e <argstr>
    return -1;
    80005702:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005704:	10054263          	bltz	a0,80005808 <sys_link+0x13c>
  begin_op();
    80005708:	fffff097          	auipc	ra,0xfffff
    8000570c:	d2a080e7          	jalr	-726(ra) # 80004432 <begin_op>
  if((ip = namei(old)) == 0){
    80005710:	ed040513          	add	a0,s0,-304
    80005714:	fffff097          	auipc	ra,0xfffff
    80005718:	b1e080e7          	jalr	-1250(ra) # 80004232 <namei>
    8000571c:	84aa                	mv	s1,a0
    8000571e:	c551                	beqz	a0,800057aa <sys_link+0xde>
  ilock(ip);
    80005720:	ffffe097          	auipc	ra,0xffffe
    80005724:	36c080e7          	jalr	876(ra) # 80003a8c <ilock>
  if(ip->type == T_DIR){
    80005728:	04449703          	lh	a4,68(s1)
    8000572c:	4785                	li	a5,1
    8000572e:	08f70463          	beq	a4,a5,800057b6 <sys_link+0xea>
  ip->nlink++;
    80005732:	04a4d783          	lhu	a5,74(s1)
    80005736:	2785                	addw	a5,a5,1
    80005738:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000573c:	8526                	mv	a0,s1
    8000573e:	ffffe097          	auipc	ra,0xffffe
    80005742:	282080e7          	jalr	642(ra) # 800039c0 <iupdate>
  iunlock(ip);
    80005746:	8526                	mv	a0,s1
    80005748:	ffffe097          	auipc	ra,0xffffe
    8000574c:	406080e7          	jalr	1030(ra) # 80003b4e <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005750:	fd040593          	add	a1,s0,-48
    80005754:	f5040513          	add	a0,s0,-176
    80005758:	fffff097          	auipc	ra,0xfffff
    8000575c:	af8080e7          	jalr	-1288(ra) # 80004250 <nameiparent>
    80005760:	892a                	mv	s2,a0
    80005762:	c935                	beqz	a0,800057d6 <sys_link+0x10a>
  ilock(dp);
    80005764:	ffffe097          	auipc	ra,0xffffe
    80005768:	328080e7          	jalr	808(ra) # 80003a8c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000576c:	00092703          	lw	a4,0(s2)
    80005770:	409c                	lw	a5,0(s1)
    80005772:	04f71d63          	bne	a4,a5,800057cc <sys_link+0x100>
    80005776:	40d0                	lw	a2,4(s1)
    80005778:	fd040593          	add	a1,s0,-48
    8000577c:	854a                	mv	a0,s2
    8000577e:	fffff097          	auipc	ra,0xfffff
    80005782:	a02080e7          	jalr	-1534(ra) # 80004180 <dirlink>
    80005786:	04054363          	bltz	a0,800057cc <sys_link+0x100>
  iunlockput(dp);
    8000578a:	854a                	mv	a0,s2
    8000578c:	ffffe097          	auipc	ra,0xffffe
    80005790:	562080e7          	jalr	1378(ra) # 80003cee <iunlockput>
  iput(ip);
    80005794:	8526                	mv	a0,s1
    80005796:	ffffe097          	auipc	ra,0xffffe
    8000579a:	4b0080e7          	jalr	1200(ra) # 80003c46 <iput>
  end_op();
    8000579e:	fffff097          	auipc	ra,0xfffff
    800057a2:	d0e080e7          	jalr	-754(ra) # 800044ac <end_op>
  return 0;
    800057a6:	4781                	li	a5,0
    800057a8:	a085                	j	80005808 <sys_link+0x13c>
    end_op();
    800057aa:	fffff097          	auipc	ra,0xfffff
    800057ae:	d02080e7          	jalr	-766(ra) # 800044ac <end_op>
    return -1;
    800057b2:	57fd                	li	a5,-1
    800057b4:	a891                	j	80005808 <sys_link+0x13c>
    iunlockput(ip);
    800057b6:	8526                	mv	a0,s1
    800057b8:	ffffe097          	auipc	ra,0xffffe
    800057bc:	536080e7          	jalr	1334(ra) # 80003cee <iunlockput>
    end_op();
    800057c0:	fffff097          	auipc	ra,0xfffff
    800057c4:	cec080e7          	jalr	-788(ra) # 800044ac <end_op>
    return -1;
    800057c8:	57fd                	li	a5,-1
    800057ca:	a83d                	j	80005808 <sys_link+0x13c>
    iunlockput(dp);
    800057cc:	854a                	mv	a0,s2
    800057ce:	ffffe097          	auipc	ra,0xffffe
    800057d2:	520080e7          	jalr	1312(ra) # 80003cee <iunlockput>
  ilock(ip);
    800057d6:	8526                	mv	a0,s1
    800057d8:	ffffe097          	auipc	ra,0xffffe
    800057dc:	2b4080e7          	jalr	692(ra) # 80003a8c <ilock>
  ip->nlink--;
    800057e0:	04a4d783          	lhu	a5,74(s1)
    800057e4:	37fd                	addw	a5,a5,-1
    800057e6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800057ea:	8526                	mv	a0,s1
    800057ec:	ffffe097          	auipc	ra,0xffffe
    800057f0:	1d4080e7          	jalr	468(ra) # 800039c0 <iupdate>
  iunlockput(ip);
    800057f4:	8526                	mv	a0,s1
    800057f6:	ffffe097          	auipc	ra,0xffffe
    800057fa:	4f8080e7          	jalr	1272(ra) # 80003cee <iunlockput>
  end_op();
    800057fe:	fffff097          	auipc	ra,0xfffff
    80005802:	cae080e7          	jalr	-850(ra) # 800044ac <end_op>
  return -1;
    80005806:	57fd                	li	a5,-1
}
    80005808:	853e                	mv	a0,a5
    8000580a:	70b2                	ld	ra,296(sp)
    8000580c:	7412                	ld	s0,288(sp)
    8000580e:	64f2                	ld	s1,280(sp)
    80005810:	6952                	ld	s2,272(sp)
    80005812:	6155                	add	sp,sp,304
    80005814:	8082                	ret

0000000080005816 <sys_unlink>:
{
    80005816:	7151                	add	sp,sp,-240
    80005818:	f586                	sd	ra,232(sp)
    8000581a:	f1a2                	sd	s0,224(sp)
    8000581c:	eda6                	sd	s1,216(sp)
    8000581e:	e9ca                	sd	s2,208(sp)
    80005820:	e5ce                	sd	s3,200(sp)
    80005822:	1980                	add	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005824:	08000613          	li	a2,128
    80005828:	f3040593          	add	a1,s0,-208
    8000582c:	4501                	li	a0,0
    8000582e:	ffffd097          	auipc	ra,0xffffd
    80005832:	530080e7          	jalr	1328(ra) # 80002d5e <argstr>
    80005836:	18054163          	bltz	a0,800059b8 <sys_unlink+0x1a2>
  begin_op();
    8000583a:	fffff097          	auipc	ra,0xfffff
    8000583e:	bf8080e7          	jalr	-1032(ra) # 80004432 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005842:	fb040593          	add	a1,s0,-80
    80005846:	f3040513          	add	a0,s0,-208
    8000584a:	fffff097          	auipc	ra,0xfffff
    8000584e:	a06080e7          	jalr	-1530(ra) # 80004250 <nameiparent>
    80005852:	84aa                	mv	s1,a0
    80005854:	c979                	beqz	a0,8000592a <sys_unlink+0x114>
  ilock(dp);
    80005856:	ffffe097          	auipc	ra,0xffffe
    8000585a:	236080e7          	jalr	566(ra) # 80003a8c <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000585e:	00003597          	auipc	a1,0x3
    80005862:	00258593          	add	a1,a1,2 # 80008860 <syscalls+0x2b0>
    80005866:	fb040513          	add	a0,s0,-80
    8000586a:	ffffe097          	auipc	ra,0xffffe
    8000586e:	6ec080e7          	jalr	1772(ra) # 80003f56 <namecmp>
    80005872:	14050a63          	beqz	a0,800059c6 <sys_unlink+0x1b0>
    80005876:	00003597          	auipc	a1,0x3
    8000587a:	ff258593          	add	a1,a1,-14 # 80008868 <syscalls+0x2b8>
    8000587e:	fb040513          	add	a0,s0,-80
    80005882:	ffffe097          	auipc	ra,0xffffe
    80005886:	6d4080e7          	jalr	1748(ra) # 80003f56 <namecmp>
    8000588a:	12050e63          	beqz	a0,800059c6 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000588e:	f2c40613          	add	a2,s0,-212
    80005892:	fb040593          	add	a1,s0,-80
    80005896:	8526                	mv	a0,s1
    80005898:	ffffe097          	auipc	ra,0xffffe
    8000589c:	6d8080e7          	jalr	1752(ra) # 80003f70 <dirlookup>
    800058a0:	892a                	mv	s2,a0
    800058a2:	12050263          	beqz	a0,800059c6 <sys_unlink+0x1b0>
  ilock(ip);
    800058a6:	ffffe097          	auipc	ra,0xffffe
    800058aa:	1e6080e7          	jalr	486(ra) # 80003a8c <ilock>
  if(ip->nlink < 1)
    800058ae:	04a91783          	lh	a5,74(s2)
    800058b2:	08f05263          	blez	a5,80005936 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800058b6:	04491703          	lh	a4,68(s2)
    800058ba:	4785                	li	a5,1
    800058bc:	08f70563          	beq	a4,a5,80005946 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800058c0:	4641                	li	a2,16
    800058c2:	4581                	li	a1,0
    800058c4:	fc040513          	add	a0,s0,-64
    800058c8:	ffffb097          	auipc	ra,0xffffb
    800058cc:	406080e7          	jalr	1030(ra) # 80000cce <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800058d0:	4741                	li	a4,16
    800058d2:	f2c42683          	lw	a3,-212(s0)
    800058d6:	fc040613          	add	a2,s0,-64
    800058da:	4581                	li	a1,0
    800058dc:	8526                	mv	a0,s1
    800058de:	ffffe097          	auipc	ra,0xffffe
    800058e2:	55a080e7          	jalr	1370(ra) # 80003e38 <writei>
    800058e6:	47c1                	li	a5,16
    800058e8:	0af51563          	bne	a0,a5,80005992 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800058ec:	04491703          	lh	a4,68(s2)
    800058f0:	4785                	li	a5,1
    800058f2:	0af70863          	beq	a4,a5,800059a2 <sys_unlink+0x18c>
  iunlockput(dp);
    800058f6:	8526                	mv	a0,s1
    800058f8:	ffffe097          	auipc	ra,0xffffe
    800058fc:	3f6080e7          	jalr	1014(ra) # 80003cee <iunlockput>
  ip->nlink--;
    80005900:	04a95783          	lhu	a5,74(s2)
    80005904:	37fd                	addw	a5,a5,-1
    80005906:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000590a:	854a                	mv	a0,s2
    8000590c:	ffffe097          	auipc	ra,0xffffe
    80005910:	0b4080e7          	jalr	180(ra) # 800039c0 <iupdate>
  iunlockput(ip);
    80005914:	854a                	mv	a0,s2
    80005916:	ffffe097          	auipc	ra,0xffffe
    8000591a:	3d8080e7          	jalr	984(ra) # 80003cee <iunlockput>
  end_op();
    8000591e:	fffff097          	auipc	ra,0xfffff
    80005922:	b8e080e7          	jalr	-1138(ra) # 800044ac <end_op>
  return 0;
    80005926:	4501                	li	a0,0
    80005928:	a84d                	j	800059da <sys_unlink+0x1c4>
    end_op();
    8000592a:	fffff097          	auipc	ra,0xfffff
    8000592e:	b82080e7          	jalr	-1150(ra) # 800044ac <end_op>
    return -1;
    80005932:	557d                	li	a0,-1
    80005934:	a05d                	j	800059da <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005936:	00003517          	auipc	a0,0x3
    8000593a:	f3a50513          	add	a0,a0,-198 # 80008870 <syscalls+0x2c0>
    8000593e:	ffffb097          	auipc	ra,0xffffb
    80005942:	bfe080e7          	jalr	-1026(ra) # 8000053c <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005946:	04c92703          	lw	a4,76(s2)
    8000594a:	02000793          	li	a5,32
    8000594e:	f6e7f9e3          	bgeu	a5,a4,800058c0 <sys_unlink+0xaa>
    80005952:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005956:	4741                	li	a4,16
    80005958:	86ce                	mv	a3,s3
    8000595a:	f1840613          	add	a2,s0,-232
    8000595e:	4581                	li	a1,0
    80005960:	854a                	mv	a0,s2
    80005962:	ffffe097          	auipc	ra,0xffffe
    80005966:	3de080e7          	jalr	990(ra) # 80003d40 <readi>
    8000596a:	47c1                	li	a5,16
    8000596c:	00f51b63          	bne	a0,a5,80005982 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005970:	f1845783          	lhu	a5,-232(s0)
    80005974:	e7a1                	bnez	a5,800059bc <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005976:	29c1                	addw	s3,s3,16
    80005978:	04c92783          	lw	a5,76(s2)
    8000597c:	fcf9ede3          	bltu	s3,a5,80005956 <sys_unlink+0x140>
    80005980:	b781                	j	800058c0 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005982:	00003517          	auipc	a0,0x3
    80005986:	f0650513          	add	a0,a0,-250 # 80008888 <syscalls+0x2d8>
    8000598a:	ffffb097          	auipc	ra,0xffffb
    8000598e:	bb2080e7          	jalr	-1102(ra) # 8000053c <panic>
    panic("unlink: writei");
    80005992:	00003517          	auipc	a0,0x3
    80005996:	f0e50513          	add	a0,a0,-242 # 800088a0 <syscalls+0x2f0>
    8000599a:	ffffb097          	auipc	ra,0xffffb
    8000599e:	ba2080e7          	jalr	-1118(ra) # 8000053c <panic>
    dp->nlink--;
    800059a2:	04a4d783          	lhu	a5,74(s1)
    800059a6:	37fd                	addw	a5,a5,-1
    800059a8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800059ac:	8526                	mv	a0,s1
    800059ae:	ffffe097          	auipc	ra,0xffffe
    800059b2:	012080e7          	jalr	18(ra) # 800039c0 <iupdate>
    800059b6:	b781                	j	800058f6 <sys_unlink+0xe0>
    return -1;
    800059b8:	557d                	li	a0,-1
    800059ba:	a005                	j	800059da <sys_unlink+0x1c4>
    iunlockput(ip);
    800059bc:	854a                	mv	a0,s2
    800059be:	ffffe097          	auipc	ra,0xffffe
    800059c2:	330080e7          	jalr	816(ra) # 80003cee <iunlockput>
  iunlockput(dp);
    800059c6:	8526                	mv	a0,s1
    800059c8:	ffffe097          	auipc	ra,0xffffe
    800059cc:	326080e7          	jalr	806(ra) # 80003cee <iunlockput>
  end_op();
    800059d0:	fffff097          	auipc	ra,0xfffff
    800059d4:	adc080e7          	jalr	-1316(ra) # 800044ac <end_op>
  return -1;
    800059d8:	557d                	li	a0,-1
}
    800059da:	70ae                	ld	ra,232(sp)
    800059dc:	740e                	ld	s0,224(sp)
    800059de:	64ee                	ld	s1,216(sp)
    800059e0:	694e                	ld	s2,208(sp)
    800059e2:	69ae                	ld	s3,200(sp)
    800059e4:	616d                	add	sp,sp,240
    800059e6:	8082                	ret

00000000800059e8 <sys_open>:

uint64
sys_open(void)
{
    800059e8:	7131                	add	sp,sp,-192
    800059ea:	fd06                	sd	ra,184(sp)
    800059ec:	f922                	sd	s0,176(sp)
    800059ee:	f526                	sd	s1,168(sp)
    800059f0:	f14a                	sd	s2,160(sp)
    800059f2:	ed4e                	sd	s3,152(sp)
    800059f4:	0180                	add	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800059f6:	f4c40593          	add	a1,s0,-180
    800059fa:	4505                	li	a0,1
    800059fc:	ffffd097          	auipc	ra,0xffffd
    80005a00:	31e080e7          	jalr	798(ra) # 80002d1a <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005a04:	08000613          	li	a2,128
    80005a08:	f5040593          	add	a1,s0,-176
    80005a0c:	4501                	li	a0,0
    80005a0e:	ffffd097          	auipc	ra,0xffffd
    80005a12:	350080e7          	jalr	848(ra) # 80002d5e <argstr>
    80005a16:	87aa                	mv	a5,a0
    return -1;
    80005a18:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005a1a:	0a07c863          	bltz	a5,80005aca <sys_open+0xe2>

  begin_op();
    80005a1e:	fffff097          	auipc	ra,0xfffff
    80005a22:	a14080e7          	jalr	-1516(ra) # 80004432 <begin_op>

  if(omode & O_CREATE){
    80005a26:	f4c42783          	lw	a5,-180(s0)
    80005a2a:	2007f793          	and	a5,a5,512
    80005a2e:	cbdd                	beqz	a5,80005ae4 <sys_open+0xfc>
    ip = create(path, T_FILE, 0, 0);
    80005a30:	4681                	li	a3,0
    80005a32:	4601                	li	a2,0
    80005a34:	4589                	li	a1,2
    80005a36:	f5040513          	add	a0,s0,-176
    80005a3a:	00000097          	auipc	ra,0x0
    80005a3e:	97a080e7          	jalr	-1670(ra) # 800053b4 <create>
    80005a42:	84aa                	mv	s1,a0
    if(ip == 0){
    80005a44:	c951                	beqz	a0,80005ad8 <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005a46:	04449703          	lh	a4,68(s1)
    80005a4a:	478d                	li	a5,3
    80005a4c:	00f71763          	bne	a4,a5,80005a5a <sys_open+0x72>
    80005a50:	0464d703          	lhu	a4,70(s1)
    80005a54:	47a5                	li	a5,9
    80005a56:	0ce7ec63          	bltu	a5,a4,80005b2e <sys_open+0x146>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005a5a:	fffff097          	auipc	ra,0xfffff
    80005a5e:	de0080e7          	jalr	-544(ra) # 8000483a <filealloc>
    80005a62:	892a                	mv	s2,a0
    80005a64:	c56d                	beqz	a0,80005b4e <sys_open+0x166>
    80005a66:	00000097          	auipc	ra,0x0
    80005a6a:	90c080e7          	jalr	-1780(ra) # 80005372 <fdalloc>
    80005a6e:	89aa                	mv	s3,a0
    80005a70:	0c054a63          	bltz	a0,80005b44 <sys_open+0x15c>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005a74:	04449703          	lh	a4,68(s1)
    80005a78:	478d                	li	a5,3
    80005a7a:	0ef70563          	beq	a4,a5,80005b64 <sys_open+0x17c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005a7e:	4789                	li	a5,2
    80005a80:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005a84:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005a88:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005a8c:	f4c42783          	lw	a5,-180(s0)
    80005a90:	0017c713          	xor	a4,a5,1
    80005a94:	8b05                	and	a4,a4,1
    80005a96:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005a9a:	0037f713          	and	a4,a5,3
    80005a9e:	00e03733          	snez	a4,a4
    80005aa2:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005aa6:	4007f793          	and	a5,a5,1024
    80005aaa:	c791                	beqz	a5,80005ab6 <sys_open+0xce>
    80005aac:	04449703          	lh	a4,68(s1)
    80005ab0:	4789                	li	a5,2
    80005ab2:	0cf70063          	beq	a4,a5,80005b72 <sys_open+0x18a>
    itrunc(ip);
  }

  iunlock(ip);
    80005ab6:	8526                	mv	a0,s1
    80005ab8:	ffffe097          	auipc	ra,0xffffe
    80005abc:	096080e7          	jalr	150(ra) # 80003b4e <iunlock>
  end_op();
    80005ac0:	fffff097          	auipc	ra,0xfffff
    80005ac4:	9ec080e7          	jalr	-1556(ra) # 800044ac <end_op>

  return fd;
    80005ac8:	854e                	mv	a0,s3
}
    80005aca:	70ea                	ld	ra,184(sp)
    80005acc:	744a                	ld	s0,176(sp)
    80005ace:	74aa                	ld	s1,168(sp)
    80005ad0:	790a                	ld	s2,160(sp)
    80005ad2:	69ea                	ld	s3,152(sp)
    80005ad4:	6129                	add	sp,sp,192
    80005ad6:	8082                	ret
      end_op();
    80005ad8:	fffff097          	auipc	ra,0xfffff
    80005adc:	9d4080e7          	jalr	-1580(ra) # 800044ac <end_op>
      return -1;
    80005ae0:	557d                	li	a0,-1
    80005ae2:	b7e5                	j	80005aca <sys_open+0xe2>
    if((ip = namei(path)) == 0){
    80005ae4:	f5040513          	add	a0,s0,-176
    80005ae8:	ffffe097          	auipc	ra,0xffffe
    80005aec:	74a080e7          	jalr	1866(ra) # 80004232 <namei>
    80005af0:	84aa                	mv	s1,a0
    80005af2:	c905                	beqz	a0,80005b22 <sys_open+0x13a>
    ilock(ip);
    80005af4:	ffffe097          	auipc	ra,0xffffe
    80005af8:	f98080e7          	jalr	-104(ra) # 80003a8c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005afc:	04449703          	lh	a4,68(s1)
    80005b00:	4785                	li	a5,1
    80005b02:	f4f712e3          	bne	a4,a5,80005a46 <sys_open+0x5e>
    80005b06:	f4c42783          	lw	a5,-180(s0)
    80005b0a:	dba1                	beqz	a5,80005a5a <sys_open+0x72>
      iunlockput(ip);
    80005b0c:	8526                	mv	a0,s1
    80005b0e:	ffffe097          	auipc	ra,0xffffe
    80005b12:	1e0080e7          	jalr	480(ra) # 80003cee <iunlockput>
      end_op();
    80005b16:	fffff097          	auipc	ra,0xfffff
    80005b1a:	996080e7          	jalr	-1642(ra) # 800044ac <end_op>
      return -1;
    80005b1e:	557d                	li	a0,-1
    80005b20:	b76d                	j	80005aca <sys_open+0xe2>
      end_op();
    80005b22:	fffff097          	auipc	ra,0xfffff
    80005b26:	98a080e7          	jalr	-1654(ra) # 800044ac <end_op>
      return -1;
    80005b2a:	557d                	li	a0,-1
    80005b2c:	bf79                	j	80005aca <sys_open+0xe2>
    iunlockput(ip);
    80005b2e:	8526                	mv	a0,s1
    80005b30:	ffffe097          	auipc	ra,0xffffe
    80005b34:	1be080e7          	jalr	446(ra) # 80003cee <iunlockput>
    end_op();
    80005b38:	fffff097          	auipc	ra,0xfffff
    80005b3c:	974080e7          	jalr	-1676(ra) # 800044ac <end_op>
    return -1;
    80005b40:	557d                	li	a0,-1
    80005b42:	b761                	j	80005aca <sys_open+0xe2>
      fileclose(f);
    80005b44:	854a                	mv	a0,s2
    80005b46:	fffff097          	auipc	ra,0xfffff
    80005b4a:	db0080e7          	jalr	-592(ra) # 800048f6 <fileclose>
    iunlockput(ip);
    80005b4e:	8526                	mv	a0,s1
    80005b50:	ffffe097          	auipc	ra,0xffffe
    80005b54:	19e080e7          	jalr	414(ra) # 80003cee <iunlockput>
    end_op();
    80005b58:	fffff097          	auipc	ra,0xfffff
    80005b5c:	954080e7          	jalr	-1708(ra) # 800044ac <end_op>
    return -1;
    80005b60:	557d                	li	a0,-1
    80005b62:	b7a5                	j	80005aca <sys_open+0xe2>
    f->type = FD_DEVICE;
    80005b64:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005b68:	04649783          	lh	a5,70(s1)
    80005b6c:	02f91223          	sh	a5,36(s2)
    80005b70:	bf21                	j	80005a88 <sys_open+0xa0>
    itrunc(ip);
    80005b72:	8526                	mv	a0,s1
    80005b74:	ffffe097          	auipc	ra,0xffffe
    80005b78:	026080e7          	jalr	38(ra) # 80003b9a <itrunc>
    80005b7c:	bf2d                	j	80005ab6 <sys_open+0xce>

0000000080005b7e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005b7e:	7175                	add	sp,sp,-144
    80005b80:	e506                	sd	ra,136(sp)
    80005b82:	e122                	sd	s0,128(sp)
    80005b84:	0900                	add	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005b86:	fffff097          	auipc	ra,0xfffff
    80005b8a:	8ac080e7          	jalr	-1876(ra) # 80004432 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005b8e:	08000613          	li	a2,128
    80005b92:	f7040593          	add	a1,s0,-144
    80005b96:	4501                	li	a0,0
    80005b98:	ffffd097          	auipc	ra,0xffffd
    80005b9c:	1c6080e7          	jalr	454(ra) # 80002d5e <argstr>
    80005ba0:	02054963          	bltz	a0,80005bd2 <sys_mkdir+0x54>
    80005ba4:	4681                	li	a3,0
    80005ba6:	4601                	li	a2,0
    80005ba8:	4585                	li	a1,1
    80005baa:	f7040513          	add	a0,s0,-144
    80005bae:	00000097          	auipc	ra,0x0
    80005bb2:	806080e7          	jalr	-2042(ra) # 800053b4 <create>
    80005bb6:	cd11                	beqz	a0,80005bd2 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005bb8:	ffffe097          	auipc	ra,0xffffe
    80005bbc:	136080e7          	jalr	310(ra) # 80003cee <iunlockput>
  end_op();
    80005bc0:	fffff097          	auipc	ra,0xfffff
    80005bc4:	8ec080e7          	jalr	-1812(ra) # 800044ac <end_op>
  return 0;
    80005bc8:	4501                	li	a0,0
}
    80005bca:	60aa                	ld	ra,136(sp)
    80005bcc:	640a                	ld	s0,128(sp)
    80005bce:	6149                	add	sp,sp,144
    80005bd0:	8082                	ret
    end_op();
    80005bd2:	fffff097          	auipc	ra,0xfffff
    80005bd6:	8da080e7          	jalr	-1830(ra) # 800044ac <end_op>
    return -1;
    80005bda:	557d                	li	a0,-1
    80005bdc:	b7fd                	j	80005bca <sys_mkdir+0x4c>

0000000080005bde <sys_mknod>:

uint64
sys_mknod(void)
{
    80005bde:	7135                	add	sp,sp,-160
    80005be0:	ed06                	sd	ra,152(sp)
    80005be2:	e922                	sd	s0,144(sp)
    80005be4:	1100                	add	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005be6:	fffff097          	auipc	ra,0xfffff
    80005bea:	84c080e7          	jalr	-1972(ra) # 80004432 <begin_op>
  argint(1, &major);
    80005bee:	f6c40593          	add	a1,s0,-148
    80005bf2:	4505                	li	a0,1
    80005bf4:	ffffd097          	auipc	ra,0xffffd
    80005bf8:	126080e7          	jalr	294(ra) # 80002d1a <argint>
  argint(2, &minor);
    80005bfc:	f6840593          	add	a1,s0,-152
    80005c00:	4509                	li	a0,2
    80005c02:	ffffd097          	auipc	ra,0xffffd
    80005c06:	118080e7          	jalr	280(ra) # 80002d1a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c0a:	08000613          	li	a2,128
    80005c0e:	f7040593          	add	a1,s0,-144
    80005c12:	4501                	li	a0,0
    80005c14:	ffffd097          	auipc	ra,0xffffd
    80005c18:	14a080e7          	jalr	330(ra) # 80002d5e <argstr>
    80005c1c:	02054b63          	bltz	a0,80005c52 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005c20:	f6841683          	lh	a3,-152(s0)
    80005c24:	f6c41603          	lh	a2,-148(s0)
    80005c28:	458d                	li	a1,3
    80005c2a:	f7040513          	add	a0,s0,-144
    80005c2e:	fffff097          	auipc	ra,0xfffff
    80005c32:	786080e7          	jalr	1926(ra) # 800053b4 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c36:	cd11                	beqz	a0,80005c52 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c38:	ffffe097          	auipc	ra,0xffffe
    80005c3c:	0b6080e7          	jalr	182(ra) # 80003cee <iunlockput>
  end_op();
    80005c40:	fffff097          	auipc	ra,0xfffff
    80005c44:	86c080e7          	jalr	-1940(ra) # 800044ac <end_op>
  return 0;
    80005c48:	4501                	li	a0,0
}
    80005c4a:	60ea                	ld	ra,152(sp)
    80005c4c:	644a                	ld	s0,144(sp)
    80005c4e:	610d                	add	sp,sp,160
    80005c50:	8082                	ret
    end_op();
    80005c52:	fffff097          	auipc	ra,0xfffff
    80005c56:	85a080e7          	jalr	-1958(ra) # 800044ac <end_op>
    return -1;
    80005c5a:	557d                	li	a0,-1
    80005c5c:	b7fd                	j	80005c4a <sys_mknod+0x6c>

0000000080005c5e <sys_chdir>:

uint64
sys_chdir(void)
{
    80005c5e:	7135                	add	sp,sp,-160
    80005c60:	ed06                	sd	ra,152(sp)
    80005c62:	e922                	sd	s0,144(sp)
    80005c64:	e526                	sd	s1,136(sp)
    80005c66:	e14a                	sd	s2,128(sp)
    80005c68:	1100                	add	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005c6a:	ffffc097          	auipc	ra,0xffffc
    80005c6e:	d3c080e7          	jalr	-708(ra) # 800019a6 <myproc>
    80005c72:	892a                	mv	s2,a0
  
  begin_op();
    80005c74:	ffffe097          	auipc	ra,0xffffe
    80005c78:	7be080e7          	jalr	1982(ra) # 80004432 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005c7c:	08000613          	li	a2,128
    80005c80:	f6040593          	add	a1,s0,-160
    80005c84:	4501                	li	a0,0
    80005c86:	ffffd097          	auipc	ra,0xffffd
    80005c8a:	0d8080e7          	jalr	216(ra) # 80002d5e <argstr>
    80005c8e:	04054b63          	bltz	a0,80005ce4 <sys_chdir+0x86>
    80005c92:	f6040513          	add	a0,s0,-160
    80005c96:	ffffe097          	auipc	ra,0xffffe
    80005c9a:	59c080e7          	jalr	1436(ra) # 80004232 <namei>
    80005c9e:	84aa                	mv	s1,a0
    80005ca0:	c131                	beqz	a0,80005ce4 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005ca2:	ffffe097          	auipc	ra,0xffffe
    80005ca6:	dea080e7          	jalr	-534(ra) # 80003a8c <ilock>
  if(ip->type != T_DIR){
    80005caa:	04449703          	lh	a4,68(s1)
    80005cae:	4785                	li	a5,1
    80005cb0:	04f71063          	bne	a4,a5,80005cf0 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005cb4:	8526                	mv	a0,s1
    80005cb6:	ffffe097          	auipc	ra,0xffffe
    80005cba:	e98080e7          	jalr	-360(ra) # 80003b4e <iunlock>
  iput(p->cwd);
    80005cbe:	15093503          	ld	a0,336(s2)
    80005cc2:	ffffe097          	auipc	ra,0xffffe
    80005cc6:	f84080e7          	jalr	-124(ra) # 80003c46 <iput>
  end_op();
    80005cca:	ffffe097          	auipc	ra,0xffffe
    80005cce:	7e2080e7          	jalr	2018(ra) # 800044ac <end_op>
  p->cwd = ip;
    80005cd2:	14993823          	sd	s1,336(s2)
  return 0;
    80005cd6:	4501                	li	a0,0
}
    80005cd8:	60ea                	ld	ra,152(sp)
    80005cda:	644a                	ld	s0,144(sp)
    80005cdc:	64aa                	ld	s1,136(sp)
    80005cde:	690a                	ld	s2,128(sp)
    80005ce0:	610d                	add	sp,sp,160
    80005ce2:	8082                	ret
    end_op();
    80005ce4:	ffffe097          	auipc	ra,0xffffe
    80005ce8:	7c8080e7          	jalr	1992(ra) # 800044ac <end_op>
    return -1;
    80005cec:	557d                	li	a0,-1
    80005cee:	b7ed                	j	80005cd8 <sys_chdir+0x7a>
    iunlockput(ip);
    80005cf0:	8526                	mv	a0,s1
    80005cf2:	ffffe097          	auipc	ra,0xffffe
    80005cf6:	ffc080e7          	jalr	-4(ra) # 80003cee <iunlockput>
    end_op();
    80005cfa:	ffffe097          	auipc	ra,0xffffe
    80005cfe:	7b2080e7          	jalr	1970(ra) # 800044ac <end_op>
    return -1;
    80005d02:	557d                	li	a0,-1
    80005d04:	bfd1                	j	80005cd8 <sys_chdir+0x7a>

0000000080005d06 <sys_exec>:

uint64
sys_exec(void)
{
    80005d06:	7121                	add	sp,sp,-448
    80005d08:	ff06                	sd	ra,440(sp)
    80005d0a:	fb22                	sd	s0,432(sp)
    80005d0c:	f726                	sd	s1,424(sp)
    80005d0e:	f34a                	sd	s2,416(sp)
    80005d10:	ef4e                	sd	s3,408(sp)
    80005d12:	eb52                	sd	s4,400(sp)
    80005d14:	0380                	add	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005d16:	e4840593          	add	a1,s0,-440
    80005d1a:	4505                	li	a0,1
    80005d1c:	ffffd097          	auipc	ra,0xffffd
    80005d20:	020080e7          	jalr	32(ra) # 80002d3c <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005d24:	08000613          	li	a2,128
    80005d28:	f5040593          	add	a1,s0,-176
    80005d2c:	4501                	li	a0,0
    80005d2e:	ffffd097          	auipc	ra,0xffffd
    80005d32:	030080e7          	jalr	48(ra) # 80002d5e <argstr>
    80005d36:	87aa                	mv	a5,a0
    return -1;
    80005d38:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005d3a:	0c07c263          	bltz	a5,80005dfe <sys_exec+0xf8>
  }
  memset(argv, 0, sizeof(argv));
    80005d3e:	10000613          	li	a2,256
    80005d42:	4581                	li	a1,0
    80005d44:	e5040513          	add	a0,s0,-432
    80005d48:	ffffb097          	auipc	ra,0xffffb
    80005d4c:	f86080e7          	jalr	-122(ra) # 80000cce <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005d50:	e5040493          	add	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005d54:	89a6                	mv	s3,s1
    80005d56:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005d58:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005d5c:	00391513          	sll	a0,s2,0x3
    80005d60:	e4040593          	add	a1,s0,-448
    80005d64:	e4843783          	ld	a5,-440(s0)
    80005d68:	953e                	add	a0,a0,a5
    80005d6a:	ffffd097          	auipc	ra,0xffffd
    80005d6e:	f16080e7          	jalr	-234(ra) # 80002c80 <fetchaddr>
    80005d72:	02054a63          	bltz	a0,80005da6 <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80005d76:	e4043783          	ld	a5,-448(s0)
    80005d7a:	c3b9                	beqz	a5,80005dc0 <sys_exec+0xba>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005d7c:	ffffb097          	auipc	ra,0xffffb
    80005d80:	d66080e7          	jalr	-666(ra) # 80000ae2 <kalloc>
    80005d84:	85aa                	mv	a1,a0
    80005d86:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005d8a:	cd11                	beqz	a0,80005da6 <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005d8c:	6605                	lui	a2,0x1
    80005d8e:	e4043503          	ld	a0,-448(s0)
    80005d92:	ffffd097          	auipc	ra,0xffffd
    80005d96:	f40080e7          	jalr	-192(ra) # 80002cd2 <fetchstr>
    80005d9a:	00054663          	bltz	a0,80005da6 <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80005d9e:	0905                	add	s2,s2,1
    80005da0:	09a1                	add	s3,s3,8
    80005da2:	fb491de3          	bne	s2,s4,80005d5c <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005da6:	f5040913          	add	s2,s0,-176
    80005daa:	6088                	ld	a0,0(s1)
    80005dac:	c921                	beqz	a0,80005dfc <sys_exec+0xf6>
    kfree(argv[i]);
    80005dae:	ffffb097          	auipc	ra,0xffffb
    80005db2:	c36080e7          	jalr	-970(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005db6:	04a1                	add	s1,s1,8
    80005db8:	ff2499e3          	bne	s1,s2,80005daa <sys_exec+0xa4>
  return -1;
    80005dbc:	557d                	li	a0,-1
    80005dbe:	a081                	j	80005dfe <sys_exec+0xf8>
      argv[i] = 0;
    80005dc0:	0009079b          	sext.w	a5,s2
    80005dc4:	078e                	sll	a5,a5,0x3
    80005dc6:	fd078793          	add	a5,a5,-48
    80005dca:	97a2                	add	a5,a5,s0
    80005dcc:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005dd0:	e5040593          	add	a1,s0,-432
    80005dd4:	f5040513          	add	a0,s0,-176
    80005dd8:	fffff097          	auipc	ra,0xfffff
    80005ddc:	194080e7          	jalr	404(ra) # 80004f6c <exec>
    80005de0:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005de2:	f5040993          	add	s3,s0,-176
    80005de6:	6088                	ld	a0,0(s1)
    80005de8:	c901                	beqz	a0,80005df8 <sys_exec+0xf2>
    kfree(argv[i]);
    80005dea:	ffffb097          	auipc	ra,0xffffb
    80005dee:	bfa080e7          	jalr	-1030(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005df2:	04a1                	add	s1,s1,8
    80005df4:	ff3499e3          	bne	s1,s3,80005de6 <sys_exec+0xe0>
  return ret;
    80005df8:	854a                	mv	a0,s2
    80005dfa:	a011                	j	80005dfe <sys_exec+0xf8>
  return -1;
    80005dfc:	557d                	li	a0,-1
}
    80005dfe:	70fa                	ld	ra,440(sp)
    80005e00:	745a                	ld	s0,432(sp)
    80005e02:	74ba                	ld	s1,424(sp)
    80005e04:	791a                	ld	s2,416(sp)
    80005e06:	69fa                	ld	s3,408(sp)
    80005e08:	6a5a                	ld	s4,400(sp)
    80005e0a:	6139                	add	sp,sp,448
    80005e0c:	8082                	ret

0000000080005e0e <sys_pipe>:

uint64
sys_pipe(void)
{
    80005e0e:	7139                	add	sp,sp,-64
    80005e10:	fc06                	sd	ra,56(sp)
    80005e12:	f822                	sd	s0,48(sp)
    80005e14:	f426                	sd	s1,40(sp)
    80005e16:	0080                	add	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005e18:	ffffc097          	auipc	ra,0xffffc
    80005e1c:	b8e080e7          	jalr	-1138(ra) # 800019a6 <myproc>
    80005e20:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005e22:	fd840593          	add	a1,s0,-40
    80005e26:	4501                	li	a0,0
    80005e28:	ffffd097          	auipc	ra,0xffffd
    80005e2c:	f14080e7          	jalr	-236(ra) # 80002d3c <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005e30:	fc840593          	add	a1,s0,-56
    80005e34:	fd040513          	add	a0,s0,-48
    80005e38:	fffff097          	auipc	ra,0xfffff
    80005e3c:	dea080e7          	jalr	-534(ra) # 80004c22 <pipealloc>
    return -1;
    80005e40:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005e42:	0c054463          	bltz	a0,80005f0a <sys_pipe+0xfc>
  fd0 = -1;
    80005e46:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005e4a:	fd043503          	ld	a0,-48(s0)
    80005e4e:	fffff097          	auipc	ra,0xfffff
    80005e52:	524080e7          	jalr	1316(ra) # 80005372 <fdalloc>
    80005e56:	fca42223          	sw	a0,-60(s0)
    80005e5a:	08054b63          	bltz	a0,80005ef0 <sys_pipe+0xe2>
    80005e5e:	fc843503          	ld	a0,-56(s0)
    80005e62:	fffff097          	auipc	ra,0xfffff
    80005e66:	510080e7          	jalr	1296(ra) # 80005372 <fdalloc>
    80005e6a:	fca42023          	sw	a0,-64(s0)
    80005e6e:	06054863          	bltz	a0,80005ede <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e72:	4691                	li	a3,4
    80005e74:	fc440613          	add	a2,s0,-60
    80005e78:	fd843583          	ld	a1,-40(s0)
    80005e7c:	68a8                	ld	a0,80(s1)
    80005e7e:	ffffb097          	auipc	ra,0xffffb
    80005e82:	7e8080e7          	jalr	2024(ra) # 80001666 <copyout>
    80005e86:	02054063          	bltz	a0,80005ea6 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005e8a:	4691                	li	a3,4
    80005e8c:	fc040613          	add	a2,s0,-64
    80005e90:	fd843583          	ld	a1,-40(s0)
    80005e94:	0591                	add	a1,a1,4
    80005e96:	68a8                	ld	a0,80(s1)
    80005e98:	ffffb097          	auipc	ra,0xffffb
    80005e9c:	7ce080e7          	jalr	1998(ra) # 80001666 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005ea0:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005ea2:	06055463          	bgez	a0,80005f0a <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005ea6:	fc442783          	lw	a5,-60(s0)
    80005eaa:	07e9                	add	a5,a5,26
    80005eac:	078e                	sll	a5,a5,0x3
    80005eae:	97a6                	add	a5,a5,s1
    80005eb0:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005eb4:	fc042783          	lw	a5,-64(s0)
    80005eb8:	07e9                	add	a5,a5,26
    80005eba:	078e                	sll	a5,a5,0x3
    80005ebc:	94be                	add	s1,s1,a5
    80005ebe:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005ec2:	fd043503          	ld	a0,-48(s0)
    80005ec6:	fffff097          	auipc	ra,0xfffff
    80005eca:	a30080e7          	jalr	-1488(ra) # 800048f6 <fileclose>
    fileclose(wf);
    80005ece:	fc843503          	ld	a0,-56(s0)
    80005ed2:	fffff097          	auipc	ra,0xfffff
    80005ed6:	a24080e7          	jalr	-1500(ra) # 800048f6 <fileclose>
    return -1;
    80005eda:	57fd                	li	a5,-1
    80005edc:	a03d                	j	80005f0a <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005ede:	fc442783          	lw	a5,-60(s0)
    80005ee2:	0007c763          	bltz	a5,80005ef0 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005ee6:	07e9                	add	a5,a5,26
    80005ee8:	078e                	sll	a5,a5,0x3
    80005eea:	97a6                	add	a5,a5,s1
    80005eec:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005ef0:	fd043503          	ld	a0,-48(s0)
    80005ef4:	fffff097          	auipc	ra,0xfffff
    80005ef8:	a02080e7          	jalr	-1534(ra) # 800048f6 <fileclose>
    fileclose(wf);
    80005efc:	fc843503          	ld	a0,-56(s0)
    80005f00:	fffff097          	auipc	ra,0xfffff
    80005f04:	9f6080e7          	jalr	-1546(ra) # 800048f6 <fileclose>
    return -1;
    80005f08:	57fd                	li	a5,-1
}
    80005f0a:	853e                	mv	a0,a5
    80005f0c:	70e2                	ld	ra,56(sp)
    80005f0e:	7442                	ld	s0,48(sp)
    80005f10:	74a2                	ld	s1,40(sp)
    80005f12:	6121                	add	sp,sp,64
    80005f14:	8082                	ret
	...

0000000080005f20 <kernelvec>:
    80005f20:	7111                	add	sp,sp,-256
    80005f22:	e006                	sd	ra,0(sp)
    80005f24:	e40a                	sd	sp,8(sp)
    80005f26:	e80e                	sd	gp,16(sp)
    80005f28:	ec12                	sd	tp,24(sp)
    80005f2a:	f016                	sd	t0,32(sp)
    80005f2c:	f41a                	sd	t1,40(sp)
    80005f2e:	f81e                	sd	t2,48(sp)
    80005f30:	fc22                	sd	s0,56(sp)
    80005f32:	e0a6                	sd	s1,64(sp)
    80005f34:	e4aa                	sd	a0,72(sp)
    80005f36:	e8ae                	sd	a1,80(sp)
    80005f38:	ecb2                	sd	a2,88(sp)
    80005f3a:	f0b6                	sd	a3,96(sp)
    80005f3c:	f4ba                	sd	a4,104(sp)
    80005f3e:	f8be                	sd	a5,112(sp)
    80005f40:	fcc2                	sd	a6,120(sp)
    80005f42:	e146                	sd	a7,128(sp)
    80005f44:	e54a                	sd	s2,136(sp)
    80005f46:	e94e                	sd	s3,144(sp)
    80005f48:	ed52                	sd	s4,152(sp)
    80005f4a:	f156                	sd	s5,160(sp)
    80005f4c:	f55a                	sd	s6,168(sp)
    80005f4e:	f95e                	sd	s7,176(sp)
    80005f50:	fd62                	sd	s8,184(sp)
    80005f52:	e1e6                	sd	s9,192(sp)
    80005f54:	e5ea                	sd	s10,200(sp)
    80005f56:	e9ee                	sd	s11,208(sp)
    80005f58:	edf2                	sd	t3,216(sp)
    80005f5a:	f1f6                	sd	t4,224(sp)
    80005f5c:	f5fa                	sd	t5,232(sp)
    80005f5e:	f9fe                	sd	t6,240(sp)
    80005f60:	c17fc0ef          	jal	80002b76 <kerneltrap>
    80005f64:	6082                	ld	ra,0(sp)
    80005f66:	6122                	ld	sp,8(sp)
    80005f68:	61c2                	ld	gp,16(sp)
    80005f6a:	7282                	ld	t0,32(sp)
    80005f6c:	7322                	ld	t1,40(sp)
    80005f6e:	73c2                	ld	t2,48(sp)
    80005f70:	7462                	ld	s0,56(sp)
    80005f72:	6486                	ld	s1,64(sp)
    80005f74:	6526                	ld	a0,72(sp)
    80005f76:	65c6                	ld	a1,80(sp)
    80005f78:	6666                	ld	a2,88(sp)
    80005f7a:	7686                	ld	a3,96(sp)
    80005f7c:	7726                	ld	a4,104(sp)
    80005f7e:	77c6                	ld	a5,112(sp)
    80005f80:	7866                	ld	a6,120(sp)
    80005f82:	688a                	ld	a7,128(sp)
    80005f84:	692a                	ld	s2,136(sp)
    80005f86:	69ca                	ld	s3,144(sp)
    80005f88:	6a6a                	ld	s4,152(sp)
    80005f8a:	7a8a                	ld	s5,160(sp)
    80005f8c:	7b2a                	ld	s6,168(sp)
    80005f8e:	7bca                	ld	s7,176(sp)
    80005f90:	7c6a                	ld	s8,184(sp)
    80005f92:	6c8e                	ld	s9,192(sp)
    80005f94:	6d2e                	ld	s10,200(sp)
    80005f96:	6dce                	ld	s11,208(sp)
    80005f98:	6e6e                	ld	t3,216(sp)
    80005f9a:	7e8e                	ld	t4,224(sp)
    80005f9c:	7f2e                	ld	t5,232(sp)
    80005f9e:	7fce                	ld	t6,240(sp)
    80005fa0:	6111                	add	sp,sp,256
    80005fa2:	10200073          	sret
    80005fa6:	00000013          	nop
    80005faa:	00000013          	nop
    80005fae:	0001                	nop

0000000080005fb0 <timervec>:
    80005fb0:	34051573          	csrrw	a0,mscratch,a0
    80005fb4:	e10c                	sd	a1,0(a0)
    80005fb6:	e510                	sd	a2,8(a0)
    80005fb8:	e914                	sd	a3,16(a0)
    80005fba:	6d0c                	ld	a1,24(a0)
    80005fbc:	7110                	ld	a2,32(a0)
    80005fbe:	6194                	ld	a3,0(a1)
    80005fc0:	96b2                	add	a3,a3,a2
    80005fc2:	e194                	sd	a3,0(a1)
    80005fc4:	4589                	li	a1,2
    80005fc6:	14459073          	csrw	sip,a1
    80005fca:	6914                	ld	a3,16(a0)
    80005fcc:	6510                	ld	a2,8(a0)
    80005fce:	610c                	ld	a1,0(a0)
    80005fd0:	34051573          	csrrw	a0,mscratch,a0
    80005fd4:	30200073          	mret
	...

0000000080005fda <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005fda:	1141                	add	sp,sp,-16
    80005fdc:	e422                	sd	s0,8(sp)
    80005fde:	0800                	add	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005fe0:	0c0007b7          	lui	a5,0xc000
    80005fe4:	4705                	li	a4,1
    80005fe6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005fe8:	c3d8                	sw	a4,4(a5)
}
    80005fea:	6422                	ld	s0,8(sp)
    80005fec:	0141                	add	sp,sp,16
    80005fee:	8082                	ret

0000000080005ff0 <plicinithart>:

void
plicinithart(void)
{
    80005ff0:	1141                	add	sp,sp,-16
    80005ff2:	e406                	sd	ra,8(sp)
    80005ff4:	e022                	sd	s0,0(sp)
    80005ff6:	0800                	add	s0,sp,16
  int hart = cpuid();
    80005ff8:	ffffc097          	auipc	ra,0xffffc
    80005ffc:	982080e7          	jalr	-1662(ra) # 8000197a <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006000:	0085171b          	sllw	a4,a0,0x8
    80006004:	0c0027b7          	lui	a5,0xc002
    80006008:	97ba                	add	a5,a5,a4
    8000600a:	40200713          	li	a4,1026
    8000600e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006012:	00d5151b          	sllw	a0,a0,0xd
    80006016:	0c2017b7          	lui	a5,0xc201
    8000601a:	97aa                	add	a5,a5,a0
    8000601c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006020:	60a2                	ld	ra,8(sp)
    80006022:	6402                	ld	s0,0(sp)
    80006024:	0141                	add	sp,sp,16
    80006026:	8082                	ret

0000000080006028 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006028:	1141                	add	sp,sp,-16
    8000602a:	e406                	sd	ra,8(sp)
    8000602c:	e022                	sd	s0,0(sp)
    8000602e:	0800                	add	s0,sp,16
  int hart = cpuid();
    80006030:	ffffc097          	auipc	ra,0xffffc
    80006034:	94a080e7          	jalr	-1718(ra) # 8000197a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006038:	00d5151b          	sllw	a0,a0,0xd
    8000603c:	0c2017b7          	lui	a5,0xc201
    80006040:	97aa                	add	a5,a5,a0
  return irq;
}
    80006042:	43c8                	lw	a0,4(a5)
    80006044:	60a2                	ld	ra,8(sp)
    80006046:	6402                	ld	s0,0(sp)
    80006048:	0141                	add	sp,sp,16
    8000604a:	8082                	ret

000000008000604c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000604c:	1101                	add	sp,sp,-32
    8000604e:	ec06                	sd	ra,24(sp)
    80006050:	e822                	sd	s0,16(sp)
    80006052:	e426                	sd	s1,8(sp)
    80006054:	1000                	add	s0,sp,32
    80006056:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006058:	ffffc097          	auipc	ra,0xffffc
    8000605c:	922080e7          	jalr	-1758(ra) # 8000197a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006060:	00d5151b          	sllw	a0,a0,0xd
    80006064:	0c2017b7          	lui	a5,0xc201
    80006068:	97aa                	add	a5,a5,a0
    8000606a:	c3c4                	sw	s1,4(a5)
}
    8000606c:	60e2                	ld	ra,24(sp)
    8000606e:	6442                	ld	s0,16(sp)
    80006070:	64a2                	ld	s1,8(sp)
    80006072:	6105                	add	sp,sp,32
    80006074:	8082                	ret

0000000080006076 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006076:	1141                	add	sp,sp,-16
    80006078:	e406                	sd	ra,8(sp)
    8000607a:	e022                	sd	s0,0(sp)
    8000607c:	0800                	add	s0,sp,16
  if(i >= NUM)
    8000607e:	479d                	li	a5,7
    80006080:	04a7cc63          	blt	a5,a0,800060d8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006084:	0001c797          	auipc	a5,0x1c
    80006088:	61c78793          	add	a5,a5,1564 # 800226a0 <disk>
    8000608c:	97aa                	add	a5,a5,a0
    8000608e:	0187c783          	lbu	a5,24(a5)
    80006092:	ebb9                	bnez	a5,800060e8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006094:	00451693          	sll	a3,a0,0x4
    80006098:	0001c797          	auipc	a5,0x1c
    8000609c:	60878793          	add	a5,a5,1544 # 800226a0 <disk>
    800060a0:	6398                	ld	a4,0(a5)
    800060a2:	9736                	add	a4,a4,a3
    800060a4:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800060a8:	6398                	ld	a4,0(a5)
    800060aa:	9736                	add	a4,a4,a3
    800060ac:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800060b0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800060b4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800060b8:	97aa                	add	a5,a5,a0
    800060ba:	4705                	li	a4,1
    800060bc:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800060c0:	0001c517          	auipc	a0,0x1c
    800060c4:	5f850513          	add	a0,a0,1528 # 800226b8 <disk+0x18>
    800060c8:	ffffc097          	auipc	ra,0xffffc
    800060cc:	248080e7          	jalr	584(ra) # 80002310 <wakeup>
}
    800060d0:	60a2                	ld	ra,8(sp)
    800060d2:	6402                	ld	s0,0(sp)
    800060d4:	0141                	add	sp,sp,16
    800060d6:	8082                	ret
    panic("free_desc 1");
    800060d8:	00002517          	auipc	a0,0x2
    800060dc:	7d850513          	add	a0,a0,2008 # 800088b0 <syscalls+0x300>
    800060e0:	ffffa097          	auipc	ra,0xffffa
    800060e4:	45c080e7          	jalr	1116(ra) # 8000053c <panic>
    panic("free_desc 2");
    800060e8:	00002517          	auipc	a0,0x2
    800060ec:	7d850513          	add	a0,a0,2008 # 800088c0 <syscalls+0x310>
    800060f0:	ffffa097          	auipc	ra,0xffffa
    800060f4:	44c080e7          	jalr	1100(ra) # 8000053c <panic>

00000000800060f8 <virtio_disk_init>:
{
    800060f8:	1101                	add	sp,sp,-32
    800060fa:	ec06                	sd	ra,24(sp)
    800060fc:	e822                	sd	s0,16(sp)
    800060fe:	e426                	sd	s1,8(sp)
    80006100:	e04a                	sd	s2,0(sp)
    80006102:	1000                	add	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006104:	00002597          	auipc	a1,0x2
    80006108:	7cc58593          	add	a1,a1,1996 # 800088d0 <syscalls+0x320>
    8000610c:	0001c517          	auipc	a0,0x1c
    80006110:	6bc50513          	add	a0,a0,1724 # 800227c8 <disk+0x128>
    80006114:	ffffb097          	auipc	ra,0xffffb
    80006118:	a2e080e7          	jalr	-1490(ra) # 80000b42 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000611c:	100017b7          	lui	a5,0x10001
    80006120:	4398                	lw	a4,0(a5)
    80006122:	2701                	sext.w	a4,a4
    80006124:	747277b7          	lui	a5,0x74727
    80006128:	97678793          	add	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000612c:	14f71b63          	bne	a4,a5,80006282 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006130:	100017b7          	lui	a5,0x10001
    80006134:	43dc                	lw	a5,4(a5)
    80006136:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006138:	4709                	li	a4,2
    8000613a:	14e79463          	bne	a5,a4,80006282 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000613e:	100017b7          	lui	a5,0x10001
    80006142:	479c                	lw	a5,8(a5)
    80006144:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006146:	12e79e63          	bne	a5,a4,80006282 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000614a:	100017b7          	lui	a5,0x10001
    8000614e:	47d8                	lw	a4,12(a5)
    80006150:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006152:	554d47b7          	lui	a5,0x554d4
    80006156:	55178793          	add	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000615a:	12f71463          	bne	a4,a5,80006282 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000615e:	100017b7          	lui	a5,0x10001
    80006162:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006166:	4705                	li	a4,1
    80006168:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000616a:	470d                	li	a4,3
    8000616c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000616e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006170:	c7ffe6b7          	lui	a3,0xc7ffe
    80006174:	75f68693          	add	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdbf7f>
    80006178:	8f75                	and	a4,a4,a3
    8000617a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000617c:	472d                	li	a4,11
    8000617e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006180:	5bbc                	lw	a5,112(a5)
    80006182:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006186:	8ba1                	and	a5,a5,8
    80006188:	10078563          	beqz	a5,80006292 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000618c:	100017b7          	lui	a5,0x10001
    80006190:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006194:	43fc                	lw	a5,68(a5)
    80006196:	2781                	sext.w	a5,a5
    80006198:	10079563          	bnez	a5,800062a2 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000619c:	100017b7          	lui	a5,0x10001
    800061a0:	5bdc                	lw	a5,52(a5)
    800061a2:	2781                	sext.w	a5,a5
  if(max == 0)
    800061a4:	10078763          	beqz	a5,800062b2 <virtio_disk_init+0x1ba>
  if(max < NUM)
    800061a8:	471d                	li	a4,7
    800061aa:	10f77c63          	bgeu	a4,a5,800062c2 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    800061ae:	ffffb097          	auipc	ra,0xffffb
    800061b2:	934080e7          	jalr	-1740(ra) # 80000ae2 <kalloc>
    800061b6:	0001c497          	auipc	s1,0x1c
    800061ba:	4ea48493          	add	s1,s1,1258 # 800226a0 <disk>
    800061be:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800061c0:	ffffb097          	auipc	ra,0xffffb
    800061c4:	922080e7          	jalr	-1758(ra) # 80000ae2 <kalloc>
    800061c8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800061ca:	ffffb097          	auipc	ra,0xffffb
    800061ce:	918080e7          	jalr	-1768(ra) # 80000ae2 <kalloc>
    800061d2:	87aa                	mv	a5,a0
    800061d4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800061d6:	6088                	ld	a0,0(s1)
    800061d8:	cd6d                	beqz	a0,800062d2 <virtio_disk_init+0x1da>
    800061da:	0001c717          	auipc	a4,0x1c
    800061de:	4ce73703          	ld	a4,1230(a4) # 800226a8 <disk+0x8>
    800061e2:	cb65                	beqz	a4,800062d2 <virtio_disk_init+0x1da>
    800061e4:	c7fd                	beqz	a5,800062d2 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    800061e6:	6605                	lui	a2,0x1
    800061e8:	4581                	li	a1,0
    800061ea:	ffffb097          	auipc	ra,0xffffb
    800061ee:	ae4080e7          	jalr	-1308(ra) # 80000cce <memset>
  memset(disk.avail, 0, PGSIZE);
    800061f2:	0001c497          	auipc	s1,0x1c
    800061f6:	4ae48493          	add	s1,s1,1198 # 800226a0 <disk>
    800061fa:	6605                	lui	a2,0x1
    800061fc:	4581                	li	a1,0
    800061fe:	6488                	ld	a0,8(s1)
    80006200:	ffffb097          	auipc	ra,0xffffb
    80006204:	ace080e7          	jalr	-1330(ra) # 80000cce <memset>
  memset(disk.used, 0, PGSIZE);
    80006208:	6605                	lui	a2,0x1
    8000620a:	4581                	li	a1,0
    8000620c:	6888                	ld	a0,16(s1)
    8000620e:	ffffb097          	auipc	ra,0xffffb
    80006212:	ac0080e7          	jalr	-1344(ra) # 80000cce <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006216:	100017b7          	lui	a5,0x10001
    8000621a:	4721                	li	a4,8
    8000621c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    8000621e:	4098                	lw	a4,0(s1)
    80006220:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006224:	40d8                	lw	a4,4(s1)
    80006226:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000622a:	6498                	ld	a4,8(s1)
    8000622c:	0007069b          	sext.w	a3,a4
    80006230:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006234:	9701                	sra	a4,a4,0x20
    80006236:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000623a:	6898                	ld	a4,16(s1)
    8000623c:	0007069b          	sext.w	a3,a4
    80006240:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006244:	9701                	sra	a4,a4,0x20
    80006246:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000624a:	4705                	li	a4,1
    8000624c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    8000624e:	00e48c23          	sb	a4,24(s1)
    80006252:	00e48ca3          	sb	a4,25(s1)
    80006256:	00e48d23          	sb	a4,26(s1)
    8000625a:	00e48da3          	sb	a4,27(s1)
    8000625e:	00e48e23          	sb	a4,28(s1)
    80006262:	00e48ea3          	sb	a4,29(s1)
    80006266:	00e48f23          	sb	a4,30(s1)
    8000626a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000626e:	00496913          	or	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006272:	0727a823          	sw	s2,112(a5)
}
    80006276:	60e2                	ld	ra,24(sp)
    80006278:	6442                	ld	s0,16(sp)
    8000627a:	64a2                	ld	s1,8(sp)
    8000627c:	6902                	ld	s2,0(sp)
    8000627e:	6105                	add	sp,sp,32
    80006280:	8082                	ret
    panic("could not find virtio disk");
    80006282:	00002517          	auipc	a0,0x2
    80006286:	65e50513          	add	a0,a0,1630 # 800088e0 <syscalls+0x330>
    8000628a:	ffffa097          	auipc	ra,0xffffa
    8000628e:	2b2080e7          	jalr	690(ra) # 8000053c <panic>
    panic("virtio disk FEATURES_OK unset");
    80006292:	00002517          	auipc	a0,0x2
    80006296:	66e50513          	add	a0,a0,1646 # 80008900 <syscalls+0x350>
    8000629a:	ffffa097          	auipc	ra,0xffffa
    8000629e:	2a2080e7          	jalr	674(ra) # 8000053c <panic>
    panic("virtio disk should not be ready");
    800062a2:	00002517          	auipc	a0,0x2
    800062a6:	67e50513          	add	a0,a0,1662 # 80008920 <syscalls+0x370>
    800062aa:	ffffa097          	auipc	ra,0xffffa
    800062ae:	292080e7          	jalr	658(ra) # 8000053c <panic>
    panic("virtio disk has no queue 0");
    800062b2:	00002517          	auipc	a0,0x2
    800062b6:	68e50513          	add	a0,a0,1678 # 80008940 <syscalls+0x390>
    800062ba:	ffffa097          	auipc	ra,0xffffa
    800062be:	282080e7          	jalr	642(ra) # 8000053c <panic>
    panic("virtio disk max queue too short");
    800062c2:	00002517          	auipc	a0,0x2
    800062c6:	69e50513          	add	a0,a0,1694 # 80008960 <syscalls+0x3b0>
    800062ca:	ffffa097          	auipc	ra,0xffffa
    800062ce:	272080e7          	jalr	626(ra) # 8000053c <panic>
    panic("virtio disk kalloc");
    800062d2:	00002517          	auipc	a0,0x2
    800062d6:	6ae50513          	add	a0,a0,1710 # 80008980 <syscalls+0x3d0>
    800062da:	ffffa097          	auipc	ra,0xffffa
    800062de:	262080e7          	jalr	610(ra) # 8000053c <panic>

00000000800062e2 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800062e2:	7159                	add	sp,sp,-112
    800062e4:	f486                	sd	ra,104(sp)
    800062e6:	f0a2                	sd	s0,96(sp)
    800062e8:	eca6                	sd	s1,88(sp)
    800062ea:	e8ca                	sd	s2,80(sp)
    800062ec:	e4ce                	sd	s3,72(sp)
    800062ee:	e0d2                	sd	s4,64(sp)
    800062f0:	fc56                	sd	s5,56(sp)
    800062f2:	f85a                	sd	s6,48(sp)
    800062f4:	f45e                	sd	s7,40(sp)
    800062f6:	f062                	sd	s8,32(sp)
    800062f8:	ec66                	sd	s9,24(sp)
    800062fa:	e86a                	sd	s10,16(sp)
    800062fc:	1880                	add	s0,sp,112
    800062fe:	8a2a                	mv	s4,a0
    80006300:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006302:	00c52c83          	lw	s9,12(a0)
    80006306:	001c9c9b          	sllw	s9,s9,0x1
    8000630a:	1c82                	sll	s9,s9,0x20
    8000630c:	020cdc93          	srl	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006310:	0001c517          	auipc	a0,0x1c
    80006314:	4b850513          	add	a0,a0,1208 # 800227c8 <disk+0x128>
    80006318:	ffffb097          	auipc	ra,0xffffb
    8000631c:	8ba080e7          	jalr	-1862(ra) # 80000bd2 <acquire>
  for(int i = 0; i < 3; i++){
    80006320:	4901                	li	s2,0
  for(int i = 0; i < NUM; i++){
    80006322:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006324:	0001cb17          	auipc	s6,0x1c
    80006328:	37cb0b13          	add	s6,s6,892 # 800226a0 <disk>
  for(int i = 0; i < 3; i++){
    8000632c:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000632e:	0001cc17          	auipc	s8,0x1c
    80006332:	49ac0c13          	add	s8,s8,1178 # 800227c8 <disk+0x128>
    80006336:	a095                	j	8000639a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80006338:	00fb0733          	add	a4,s6,a5
    8000633c:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006340:	c11c                	sw	a5,0(a0)
    if(idx[i] < 0){
    80006342:	0207c563          	bltz	a5,8000636c <virtio_disk_rw+0x8a>
  for(int i = 0; i < 3; i++){
    80006346:	2605                	addw	a2,a2,1 # 1001 <_entry-0x7fffefff>
    80006348:	0591                	add	a1,a1,4
    8000634a:	05560d63          	beq	a2,s5,800063a4 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    8000634e:	852e                	mv	a0,a1
  for(int i = 0; i < NUM; i++){
    80006350:	0001c717          	auipc	a4,0x1c
    80006354:	35070713          	add	a4,a4,848 # 800226a0 <disk>
    80006358:	87ca                	mv	a5,s2
    if(disk.free[i]){
    8000635a:	01874683          	lbu	a3,24(a4)
    8000635e:	fee9                	bnez	a3,80006338 <virtio_disk_rw+0x56>
  for(int i = 0; i < NUM; i++){
    80006360:	2785                	addw	a5,a5,1
    80006362:	0705                	add	a4,a4,1
    80006364:	fe979be3          	bne	a5,s1,8000635a <virtio_disk_rw+0x78>
    idx[i] = alloc_desc();
    80006368:	57fd                	li	a5,-1
    8000636a:	c11c                	sw	a5,0(a0)
      for(int j = 0; j < i; j++)
    8000636c:	00c05e63          	blez	a2,80006388 <virtio_disk_rw+0xa6>
    80006370:	060a                	sll	a2,a2,0x2
    80006372:	01360d33          	add	s10,a2,s3
        free_desc(idx[j]);
    80006376:	0009a503          	lw	a0,0(s3)
    8000637a:	00000097          	auipc	ra,0x0
    8000637e:	cfc080e7          	jalr	-772(ra) # 80006076 <free_desc>
      for(int j = 0; j < i; j++)
    80006382:	0991                	add	s3,s3,4
    80006384:	ffa999e3          	bne	s3,s10,80006376 <virtio_disk_rw+0x94>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006388:	85e2                	mv	a1,s8
    8000638a:	0001c517          	auipc	a0,0x1c
    8000638e:	32e50513          	add	a0,a0,814 # 800226b8 <disk+0x18>
    80006392:	ffffc097          	auipc	ra,0xffffc
    80006396:	dce080e7          	jalr	-562(ra) # 80002160 <sleep>
  for(int i = 0; i < 3; i++){
    8000639a:	f9040993          	add	s3,s0,-112
{
    8000639e:	85ce                	mv	a1,s3
  for(int i = 0; i < 3; i++){
    800063a0:	864a                	mv	a2,s2
    800063a2:	b775                	j	8000634e <virtio_disk_rw+0x6c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800063a4:	f9042503          	lw	a0,-112(s0)
    800063a8:	00a50713          	add	a4,a0,10
    800063ac:	0712                	sll	a4,a4,0x4

  if(write)
    800063ae:	0001c797          	auipc	a5,0x1c
    800063b2:	2f278793          	add	a5,a5,754 # 800226a0 <disk>
    800063b6:	00e786b3          	add	a3,a5,a4
    800063ba:	01703633          	snez	a2,s7
    800063be:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800063c0:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    800063c4:	0196b823          	sd	s9,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800063c8:	f6070613          	add	a2,a4,-160
    800063cc:	6394                	ld	a3,0(a5)
    800063ce:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800063d0:	00870593          	add	a1,a4,8
    800063d4:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800063d6:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800063d8:	0007b803          	ld	a6,0(a5)
    800063dc:	9642                	add	a2,a2,a6
    800063de:	46c1                	li	a3,16
    800063e0:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800063e2:	4585                	li	a1,1
    800063e4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    800063e8:	f9442683          	lw	a3,-108(s0)
    800063ec:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800063f0:	0692                	sll	a3,a3,0x4
    800063f2:	9836                	add	a6,a6,a3
    800063f4:	058a0613          	add	a2,s4,88
    800063f8:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    800063fc:	0007b803          	ld	a6,0(a5)
    80006400:	96c2                	add	a3,a3,a6
    80006402:	40000613          	li	a2,1024
    80006406:	c690                	sw	a2,8(a3)
  if(write)
    80006408:	001bb613          	seqz	a2,s7
    8000640c:	0016161b          	sllw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006410:	00166613          	or	a2,a2,1
    80006414:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006418:	f9842603          	lw	a2,-104(s0)
    8000641c:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006420:	00250693          	add	a3,a0,2
    80006424:	0692                	sll	a3,a3,0x4
    80006426:	96be                	add	a3,a3,a5
    80006428:	58fd                	li	a7,-1
    8000642a:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000642e:	0612                	sll	a2,a2,0x4
    80006430:	9832                	add	a6,a6,a2
    80006432:	f9070713          	add	a4,a4,-112
    80006436:	973e                	add	a4,a4,a5
    80006438:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000643c:	6398                	ld	a4,0(a5)
    8000643e:	9732                	add	a4,a4,a2
    80006440:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006442:	4609                	li	a2,2
    80006444:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006448:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000644c:	00ba2223          	sw	a1,4(s4)
  disk.info[idx[0]].b = b;
    80006450:	0146b423          	sd	s4,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006454:	6794                	ld	a3,8(a5)
    80006456:	0026d703          	lhu	a4,2(a3)
    8000645a:	8b1d                	and	a4,a4,7
    8000645c:	0706                	sll	a4,a4,0x1
    8000645e:	96ba                	add	a3,a3,a4
    80006460:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006464:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006468:	6798                	ld	a4,8(a5)
    8000646a:	00275783          	lhu	a5,2(a4)
    8000646e:	2785                	addw	a5,a5,1
    80006470:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006474:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006478:	100017b7          	lui	a5,0x10001
    8000647c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006480:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006484:	0001c917          	auipc	s2,0x1c
    80006488:	34490913          	add	s2,s2,836 # 800227c8 <disk+0x128>
  while(b->disk == 1) {
    8000648c:	4485                	li	s1,1
    8000648e:	00b79c63          	bne	a5,a1,800064a6 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006492:	85ca                	mv	a1,s2
    80006494:	8552                	mv	a0,s4
    80006496:	ffffc097          	auipc	ra,0xffffc
    8000649a:	cca080e7          	jalr	-822(ra) # 80002160 <sleep>
  while(b->disk == 1) {
    8000649e:	004a2783          	lw	a5,4(s4)
    800064a2:	fe9788e3          	beq	a5,s1,80006492 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    800064a6:	f9042903          	lw	s2,-112(s0)
    800064aa:	00290713          	add	a4,s2,2
    800064ae:	0712                	sll	a4,a4,0x4
    800064b0:	0001c797          	auipc	a5,0x1c
    800064b4:	1f078793          	add	a5,a5,496 # 800226a0 <disk>
    800064b8:	97ba                	add	a5,a5,a4
    800064ba:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800064be:	0001c997          	auipc	s3,0x1c
    800064c2:	1e298993          	add	s3,s3,482 # 800226a0 <disk>
    800064c6:	00491713          	sll	a4,s2,0x4
    800064ca:	0009b783          	ld	a5,0(s3)
    800064ce:	97ba                	add	a5,a5,a4
    800064d0:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800064d4:	854a                	mv	a0,s2
    800064d6:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800064da:	00000097          	auipc	ra,0x0
    800064de:	b9c080e7          	jalr	-1124(ra) # 80006076 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800064e2:	8885                	and	s1,s1,1
    800064e4:	f0ed                	bnez	s1,800064c6 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800064e6:	0001c517          	auipc	a0,0x1c
    800064ea:	2e250513          	add	a0,a0,738 # 800227c8 <disk+0x128>
    800064ee:	ffffa097          	auipc	ra,0xffffa
    800064f2:	798080e7          	jalr	1944(ra) # 80000c86 <release>
}
    800064f6:	70a6                	ld	ra,104(sp)
    800064f8:	7406                	ld	s0,96(sp)
    800064fa:	64e6                	ld	s1,88(sp)
    800064fc:	6946                	ld	s2,80(sp)
    800064fe:	69a6                	ld	s3,72(sp)
    80006500:	6a06                	ld	s4,64(sp)
    80006502:	7ae2                	ld	s5,56(sp)
    80006504:	7b42                	ld	s6,48(sp)
    80006506:	7ba2                	ld	s7,40(sp)
    80006508:	7c02                	ld	s8,32(sp)
    8000650a:	6ce2                	ld	s9,24(sp)
    8000650c:	6d42                	ld	s10,16(sp)
    8000650e:	6165                	add	sp,sp,112
    80006510:	8082                	ret

0000000080006512 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006512:	1101                	add	sp,sp,-32
    80006514:	ec06                	sd	ra,24(sp)
    80006516:	e822                	sd	s0,16(sp)
    80006518:	e426                	sd	s1,8(sp)
    8000651a:	1000                	add	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000651c:	0001c497          	auipc	s1,0x1c
    80006520:	18448493          	add	s1,s1,388 # 800226a0 <disk>
    80006524:	0001c517          	auipc	a0,0x1c
    80006528:	2a450513          	add	a0,a0,676 # 800227c8 <disk+0x128>
    8000652c:	ffffa097          	auipc	ra,0xffffa
    80006530:	6a6080e7          	jalr	1702(ra) # 80000bd2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006534:	10001737          	lui	a4,0x10001
    80006538:	533c                	lw	a5,96(a4)
    8000653a:	8b8d                	and	a5,a5,3
    8000653c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000653e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006542:	689c                	ld	a5,16(s1)
    80006544:	0204d703          	lhu	a4,32(s1)
    80006548:	0027d783          	lhu	a5,2(a5)
    8000654c:	04f70863          	beq	a4,a5,8000659c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006550:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006554:	6898                	ld	a4,16(s1)
    80006556:	0204d783          	lhu	a5,32(s1)
    8000655a:	8b9d                	and	a5,a5,7
    8000655c:	078e                	sll	a5,a5,0x3
    8000655e:	97ba                	add	a5,a5,a4
    80006560:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006562:	00278713          	add	a4,a5,2
    80006566:	0712                	sll	a4,a4,0x4
    80006568:	9726                	add	a4,a4,s1
    8000656a:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    8000656e:	e721                	bnez	a4,800065b6 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006570:	0789                	add	a5,a5,2
    80006572:	0792                	sll	a5,a5,0x4
    80006574:	97a6                	add	a5,a5,s1
    80006576:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006578:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000657c:	ffffc097          	auipc	ra,0xffffc
    80006580:	d94080e7          	jalr	-620(ra) # 80002310 <wakeup>

    disk.used_idx += 1;
    80006584:	0204d783          	lhu	a5,32(s1)
    80006588:	2785                	addw	a5,a5,1
    8000658a:	17c2                	sll	a5,a5,0x30
    8000658c:	93c1                	srl	a5,a5,0x30
    8000658e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006592:	6898                	ld	a4,16(s1)
    80006594:	00275703          	lhu	a4,2(a4)
    80006598:	faf71ce3          	bne	a4,a5,80006550 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000659c:	0001c517          	auipc	a0,0x1c
    800065a0:	22c50513          	add	a0,a0,556 # 800227c8 <disk+0x128>
    800065a4:	ffffa097          	auipc	ra,0xffffa
    800065a8:	6e2080e7          	jalr	1762(ra) # 80000c86 <release>
}
    800065ac:	60e2                	ld	ra,24(sp)
    800065ae:	6442                	ld	s0,16(sp)
    800065b0:	64a2                	ld	s1,8(sp)
    800065b2:	6105                	add	sp,sp,32
    800065b4:	8082                	ret
      panic("virtio_disk_intr status");
    800065b6:	00002517          	auipc	a0,0x2
    800065ba:	3e250513          	add	a0,a0,994 # 80008998 <syscalls+0x3e8>
    800065be:	ffffa097          	auipc	ra,0xffffa
    800065c2:	f7e080e7          	jalr	-130(ra) # 8000053c <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	sll	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	sll	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
