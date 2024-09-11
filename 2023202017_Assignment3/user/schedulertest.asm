
user/_schedulertest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/fcntl.h"

#define NFORK 10
#define IO 5

int main() {
   0:	7139                	add	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	0080                	add	s0,sp,64
  int n, pid;
  int wtime, rtime;
  int twtime=0, trtime=0;
  for(n=0; n < NFORK;n++) {
   e:	4481                	li	s1,0
  10:	4929                	li	s2,10
      pid = fork();
  12:	00000097          	auipc	ra,0x0
  16:	338080e7          	jalr	824(ra) # 34a <fork>
      if (pid < 0)
  1a:	00054963          	bltz	a0,2c <main+0x2c>
          break;
      if (pid == 0) {
  1e:	cd0d                	beqz	a0,58 <main+0x58>
  for(n=0; n < NFORK;n++) {
  20:	2485                	addw	s1,s1,1
  22:	ff2498e3          	bne	s1,s2,12 <main+0x12>
  26:	4901                	li	s2,0
  28:	4981                	li	s3,0
  2a:	a8ad                	j	a4 <main+0xa4>
#ifdef PBS
        set_priority(80, pid); // Will only matter for PBS, set lower priority for IO bound processes 
#endif
      }
  }
  for(;n > 0; n--) {
  2c:	fe904de3          	bgtz	s1,26 <main+0x26>
  30:	4901                	li	s2,0
  32:	4981                	li	s3,0
      if(waitx(0,&wtime,&rtime) >= 0) {
          trtime += rtime;
          twtime += wtime;
      } 
  }
  printf("Average rtime %d,  wtime %d\n", trtime / NFORK, twtime / NFORK);
  34:	45a9                	li	a1,10
  36:	02b9c63b          	divw	a2,s3,a1
  3a:	02b945bb          	divw	a1,s2,a1
  3e:	00001517          	auipc	a0,0x1
  42:	84a50513          	add	a0,a0,-1974 # 888 <malloc+0xfe>
  46:	00000097          	auipc	ra,0x0
  4a:	68c080e7          	jalr	1676(ra) # 6d2 <printf>
  exit(0);
  4e:	4501                	li	a0,0
  50:	00000097          	auipc	ra,0x0
  54:	302080e7          	jalr	770(ra) # 352 <exit>
            for (volatile int i = 0; i < 1000000000; i++) {} // CPU bound process 
  58:	fc042223          	sw	zero,-60(s0)
  5c:	fc442703          	lw	a4,-60(s0)
  60:	2701                	sext.w	a4,a4
  62:	3b9ad7b7          	lui	a5,0x3b9ad
  66:	9ff78793          	add	a5,a5,-1537 # 3b9ac9ff <base+0x3b9ab9ef>
  6a:	00e7cd63          	blt	a5,a4,84 <main+0x84>
  6e:	873e                	mv	a4,a5
  70:	fc442783          	lw	a5,-60(s0)
  74:	2785                	addw	a5,a5,1
  76:	fcf42223          	sw	a5,-60(s0)
  7a:	fc442783          	lw	a5,-60(s0)
  7e:	2781                	sext.w	a5,a5
  80:	fef758e3          	bge	a4,a5,70 <main+0x70>
          printf("Process %d finished", n);
  84:	85a6                	mv	a1,s1
  86:	00000517          	auipc	a0,0x0
  8a:	7ea50513          	add	a0,a0,2026 # 870 <malloc+0xe6>
  8e:	00000097          	auipc	ra,0x0
  92:	644080e7          	jalr	1604(ra) # 6d2 <printf>
          exit(0);
  96:	4501                	li	a0,0
  98:	00000097          	auipc	ra,0x0
  9c:	2ba080e7          	jalr	698(ra) # 352 <exit>
  for(;n > 0; n--) {
  a0:	34fd                	addw	s1,s1,-1
  a2:	d8c9                	beqz	s1,34 <main+0x34>
      if(waitx(0,&wtime,&rtime) >= 0) {
  a4:	fc840613          	add	a2,s0,-56
  a8:	fcc40593          	add	a1,s0,-52
  ac:	4501                	li	a0,0
  ae:	00000097          	auipc	ra,0x0
  b2:	34c080e7          	jalr	844(ra) # 3fa <waitx>
  b6:	fe0545e3          	bltz	a0,a0 <main+0xa0>
          trtime += rtime;
  ba:	fc842783          	lw	a5,-56(s0)
  be:	0127893b          	addw	s2,a5,s2
          twtime += wtime;
  c2:	fcc42783          	lw	a5,-52(s0)
  c6:	013789bb          	addw	s3,a5,s3
  ca:	bfd9                	j	a0 <main+0xa0>

00000000000000cc <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  cc:	1141                	add	sp,sp,-16
  ce:	e406                	sd	ra,8(sp)
  d0:	e022                	sd	s0,0(sp)
  d2:	0800                	add	s0,sp,16
  extern int main();
  main();
  d4:	00000097          	auipc	ra,0x0
  d8:	f2c080e7          	jalr	-212(ra) # 0 <main>
  exit(0);
  dc:	4501                	li	a0,0
  de:	00000097          	auipc	ra,0x0
  e2:	274080e7          	jalr	628(ra) # 352 <exit>

00000000000000e6 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  e6:	1141                	add	sp,sp,-16
  e8:	e422                	sd	s0,8(sp)
  ea:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  ec:	87aa                	mv	a5,a0
  ee:	0585                	add	a1,a1,1
  f0:	0785                	add	a5,a5,1
  f2:	fff5c703          	lbu	a4,-1(a1)
  f6:	fee78fa3          	sb	a4,-1(a5)
  fa:	fb75                	bnez	a4,ee <strcpy+0x8>
    ;
  return os;
}
  fc:	6422                	ld	s0,8(sp)
  fe:	0141                	add	sp,sp,16
 100:	8082                	ret

0000000000000102 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 102:	1141                	add	sp,sp,-16
 104:	e422                	sd	s0,8(sp)
 106:	0800                	add	s0,sp,16
  while(*p && *p == *q)
 108:	00054783          	lbu	a5,0(a0)
 10c:	cb91                	beqz	a5,120 <strcmp+0x1e>
 10e:	0005c703          	lbu	a4,0(a1)
 112:	00f71763          	bne	a4,a5,120 <strcmp+0x1e>
    p++, q++;
 116:	0505                	add	a0,a0,1
 118:	0585                	add	a1,a1,1
  while(*p && *p == *q)
 11a:	00054783          	lbu	a5,0(a0)
 11e:	fbe5                	bnez	a5,10e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 120:	0005c503          	lbu	a0,0(a1)
}
 124:	40a7853b          	subw	a0,a5,a0
 128:	6422                	ld	s0,8(sp)
 12a:	0141                	add	sp,sp,16
 12c:	8082                	ret

000000000000012e <strlen>:

uint
strlen(const char *s)
{
 12e:	1141                	add	sp,sp,-16
 130:	e422                	sd	s0,8(sp)
 132:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 134:	00054783          	lbu	a5,0(a0)
 138:	cf91                	beqz	a5,154 <strlen+0x26>
 13a:	0505                	add	a0,a0,1
 13c:	87aa                	mv	a5,a0
 13e:	86be                	mv	a3,a5
 140:	0785                	add	a5,a5,1
 142:	fff7c703          	lbu	a4,-1(a5)
 146:	ff65                	bnez	a4,13e <strlen+0x10>
 148:	40a6853b          	subw	a0,a3,a0
 14c:	2505                	addw	a0,a0,1
    ;
  return n;
}
 14e:	6422                	ld	s0,8(sp)
 150:	0141                	add	sp,sp,16
 152:	8082                	ret
  for(n = 0; s[n]; n++)
 154:	4501                	li	a0,0
 156:	bfe5                	j	14e <strlen+0x20>

0000000000000158 <memset>:

void*
memset(void *dst, int c, uint n)
{
 158:	1141                	add	sp,sp,-16
 15a:	e422                	sd	s0,8(sp)
 15c:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 15e:	ca19                	beqz	a2,174 <memset+0x1c>
 160:	87aa                	mv	a5,a0
 162:	1602                	sll	a2,a2,0x20
 164:	9201                	srl	a2,a2,0x20
 166:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 16a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 16e:	0785                	add	a5,a5,1
 170:	fee79de3          	bne	a5,a4,16a <memset+0x12>
  }
  return dst;
}
 174:	6422                	ld	s0,8(sp)
 176:	0141                	add	sp,sp,16
 178:	8082                	ret

000000000000017a <strchr>:

char*
strchr(const char *s, char c)
{
 17a:	1141                	add	sp,sp,-16
 17c:	e422                	sd	s0,8(sp)
 17e:	0800                	add	s0,sp,16
  for(; *s; s++)
 180:	00054783          	lbu	a5,0(a0)
 184:	cb99                	beqz	a5,19a <strchr+0x20>
    if(*s == c)
 186:	00f58763          	beq	a1,a5,194 <strchr+0x1a>
  for(; *s; s++)
 18a:	0505                	add	a0,a0,1
 18c:	00054783          	lbu	a5,0(a0)
 190:	fbfd                	bnez	a5,186 <strchr+0xc>
      return (char*)s;
  return 0;
 192:	4501                	li	a0,0
}
 194:	6422                	ld	s0,8(sp)
 196:	0141                	add	sp,sp,16
 198:	8082                	ret
  return 0;
 19a:	4501                	li	a0,0
 19c:	bfe5                	j	194 <strchr+0x1a>

000000000000019e <gets>:

char*
gets(char *buf, int max)
{
 19e:	711d                	add	sp,sp,-96
 1a0:	ec86                	sd	ra,88(sp)
 1a2:	e8a2                	sd	s0,80(sp)
 1a4:	e4a6                	sd	s1,72(sp)
 1a6:	e0ca                	sd	s2,64(sp)
 1a8:	fc4e                	sd	s3,56(sp)
 1aa:	f852                	sd	s4,48(sp)
 1ac:	f456                	sd	s5,40(sp)
 1ae:	f05a                	sd	s6,32(sp)
 1b0:	ec5e                	sd	s7,24(sp)
 1b2:	1080                	add	s0,sp,96
 1b4:	8baa                	mv	s7,a0
 1b6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1b8:	892a                	mv	s2,a0
 1ba:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1bc:	4aa9                	li	s5,10
 1be:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1c0:	89a6                	mv	s3,s1
 1c2:	2485                	addw	s1,s1,1
 1c4:	0344d863          	bge	s1,s4,1f4 <gets+0x56>
    cc = read(0, &c, 1);
 1c8:	4605                	li	a2,1
 1ca:	faf40593          	add	a1,s0,-81
 1ce:	4501                	li	a0,0
 1d0:	00000097          	auipc	ra,0x0
 1d4:	19a080e7          	jalr	410(ra) # 36a <read>
    if(cc < 1)
 1d8:	00a05e63          	blez	a0,1f4 <gets+0x56>
    buf[i++] = c;
 1dc:	faf44783          	lbu	a5,-81(s0)
 1e0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1e4:	01578763          	beq	a5,s5,1f2 <gets+0x54>
 1e8:	0905                	add	s2,s2,1
 1ea:	fd679be3          	bne	a5,s6,1c0 <gets+0x22>
  for(i=0; i+1 < max; ){
 1ee:	89a6                	mv	s3,s1
 1f0:	a011                	j	1f4 <gets+0x56>
 1f2:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1f4:	99de                	add	s3,s3,s7
 1f6:	00098023          	sb	zero,0(s3)
  return buf;
}
 1fa:	855e                	mv	a0,s7
 1fc:	60e6                	ld	ra,88(sp)
 1fe:	6446                	ld	s0,80(sp)
 200:	64a6                	ld	s1,72(sp)
 202:	6906                	ld	s2,64(sp)
 204:	79e2                	ld	s3,56(sp)
 206:	7a42                	ld	s4,48(sp)
 208:	7aa2                	ld	s5,40(sp)
 20a:	7b02                	ld	s6,32(sp)
 20c:	6be2                	ld	s7,24(sp)
 20e:	6125                	add	sp,sp,96
 210:	8082                	ret

0000000000000212 <stat>:

int
stat(const char *n, struct stat *st)
{
 212:	1101                	add	sp,sp,-32
 214:	ec06                	sd	ra,24(sp)
 216:	e822                	sd	s0,16(sp)
 218:	e426                	sd	s1,8(sp)
 21a:	e04a                	sd	s2,0(sp)
 21c:	1000                	add	s0,sp,32
 21e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 220:	4581                	li	a1,0
 222:	00000097          	auipc	ra,0x0
 226:	170080e7          	jalr	368(ra) # 392 <open>
  if(fd < 0)
 22a:	02054563          	bltz	a0,254 <stat+0x42>
 22e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 230:	85ca                	mv	a1,s2
 232:	00000097          	auipc	ra,0x0
 236:	178080e7          	jalr	376(ra) # 3aa <fstat>
 23a:	892a                	mv	s2,a0
  close(fd);
 23c:	8526                	mv	a0,s1
 23e:	00000097          	auipc	ra,0x0
 242:	13c080e7          	jalr	316(ra) # 37a <close>
  return r;
}
 246:	854a                	mv	a0,s2
 248:	60e2                	ld	ra,24(sp)
 24a:	6442                	ld	s0,16(sp)
 24c:	64a2                	ld	s1,8(sp)
 24e:	6902                	ld	s2,0(sp)
 250:	6105                	add	sp,sp,32
 252:	8082                	ret
    return -1;
 254:	597d                	li	s2,-1
 256:	bfc5                	j	246 <stat+0x34>

0000000000000258 <atoi>:

int
atoi(const char *s)
{
 258:	1141                	add	sp,sp,-16
 25a:	e422                	sd	s0,8(sp)
 25c:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 25e:	00054683          	lbu	a3,0(a0)
 262:	fd06879b          	addw	a5,a3,-48
 266:	0ff7f793          	zext.b	a5,a5
 26a:	4625                	li	a2,9
 26c:	02f66863          	bltu	a2,a5,29c <atoi+0x44>
 270:	872a                	mv	a4,a0
  n = 0;
 272:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 274:	0705                	add	a4,a4,1
 276:	0025179b          	sllw	a5,a0,0x2
 27a:	9fa9                	addw	a5,a5,a0
 27c:	0017979b          	sllw	a5,a5,0x1
 280:	9fb5                	addw	a5,a5,a3
 282:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 286:	00074683          	lbu	a3,0(a4)
 28a:	fd06879b          	addw	a5,a3,-48
 28e:	0ff7f793          	zext.b	a5,a5
 292:	fef671e3          	bgeu	a2,a5,274 <atoi+0x1c>
  return n;
}
 296:	6422                	ld	s0,8(sp)
 298:	0141                	add	sp,sp,16
 29a:	8082                	ret
  n = 0;
 29c:	4501                	li	a0,0
 29e:	bfe5                	j	296 <atoi+0x3e>

00000000000002a0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2a0:	1141                	add	sp,sp,-16
 2a2:	e422                	sd	s0,8(sp)
 2a4:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2a6:	02b57463          	bgeu	a0,a1,2ce <memmove+0x2e>
    while(n-- > 0)
 2aa:	00c05f63          	blez	a2,2c8 <memmove+0x28>
 2ae:	1602                	sll	a2,a2,0x20
 2b0:	9201                	srl	a2,a2,0x20
 2b2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2b6:	872a                	mv	a4,a0
      *dst++ = *src++;
 2b8:	0585                	add	a1,a1,1
 2ba:	0705                	add	a4,a4,1
 2bc:	fff5c683          	lbu	a3,-1(a1)
 2c0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2c4:	fee79ae3          	bne	a5,a4,2b8 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2c8:	6422                	ld	s0,8(sp)
 2ca:	0141                	add	sp,sp,16
 2cc:	8082                	ret
    dst += n;
 2ce:	00c50733          	add	a4,a0,a2
    src += n;
 2d2:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2d4:	fec05ae3          	blez	a2,2c8 <memmove+0x28>
 2d8:	fff6079b          	addw	a5,a2,-1
 2dc:	1782                	sll	a5,a5,0x20
 2de:	9381                	srl	a5,a5,0x20
 2e0:	fff7c793          	not	a5,a5
 2e4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2e6:	15fd                	add	a1,a1,-1
 2e8:	177d                	add	a4,a4,-1
 2ea:	0005c683          	lbu	a3,0(a1)
 2ee:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2f2:	fee79ae3          	bne	a5,a4,2e6 <memmove+0x46>
 2f6:	bfc9                	j	2c8 <memmove+0x28>

00000000000002f8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2f8:	1141                	add	sp,sp,-16
 2fa:	e422                	sd	s0,8(sp)
 2fc:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2fe:	ca05                	beqz	a2,32e <memcmp+0x36>
 300:	fff6069b          	addw	a3,a2,-1
 304:	1682                	sll	a3,a3,0x20
 306:	9281                	srl	a3,a3,0x20
 308:	0685                	add	a3,a3,1
 30a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 30c:	00054783          	lbu	a5,0(a0)
 310:	0005c703          	lbu	a4,0(a1)
 314:	00e79863          	bne	a5,a4,324 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 318:	0505                	add	a0,a0,1
    p2++;
 31a:	0585                	add	a1,a1,1
  while (n-- > 0) {
 31c:	fed518e3          	bne	a0,a3,30c <memcmp+0x14>
  }
  return 0;
 320:	4501                	li	a0,0
 322:	a019                	j	328 <memcmp+0x30>
      return *p1 - *p2;
 324:	40e7853b          	subw	a0,a5,a4
}
 328:	6422                	ld	s0,8(sp)
 32a:	0141                	add	sp,sp,16
 32c:	8082                	ret
  return 0;
 32e:	4501                	li	a0,0
 330:	bfe5                	j	328 <memcmp+0x30>

0000000000000332 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 332:	1141                	add	sp,sp,-16
 334:	e406                	sd	ra,8(sp)
 336:	e022                	sd	s0,0(sp)
 338:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 33a:	00000097          	auipc	ra,0x0
 33e:	f66080e7          	jalr	-154(ra) # 2a0 <memmove>
}
 342:	60a2                	ld	ra,8(sp)
 344:	6402                	ld	s0,0(sp)
 346:	0141                	add	sp,sp,16
 348:	8082                	ret

000000000000034a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 34a:	4885                	li	a7,1
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <exit>:
.global exit
exit:
 li a7, SYS_exit
 352:	4889                	li	a7,2
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <wait>:
.global wait
wait:
 li a7, SYS_wait
 35a:	488d                	li	a7,3
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 362:	4891                	li	a7,4
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <read>:
.global read
read:
 li a7, SYS_read
 36a:	4895                	li	a7,5
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <write>:
.global write
write:
 li a7, SYS_write
 372:	48c1                	li	a7,16
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <close>:
.global close
close:
 li a7, SYS_close
 37a:	48d5                	li	a7,21
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <kill>:
.global kill
kill:
 li a7, SYS_kill
 382:	4899                	li	a7,6
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <exec>:
.global exec
exec:
 li a7, SYS_exec
 38a:	489d                	li	a7,7
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <open>:
.global open
open:
 li a7, SYS_open
 392:	48bd                	li	a7,15
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 39a:	48c5                	li	a7,17
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3a2:	48c9                	li	a7,18
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3aa:	48a1                	li	a7,8
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <link>:
.global link
link:
 li a7, SYS_link
 3b2:	48cd                	li	a7,19
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3ba:	48d1                	li	a7,20
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3c2:	48a5                	li	a7,9
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <dup>:
.global dup
dup:
 li a7, SYS_dup
 3ca:	48a9                	li	a7,10
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3d2:	48ad                	li	a7,11
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3da:	48b1                	li	a7,12
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3e2:	48b5                	li	a7,13
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3ea:	48b9                	li	a7,14
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <strace>:
.global strace
strace:
 li a7, SYS_strace
 3f2:	48d9                	li	a7,22
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 3fa:	48dd                	li	a7,23
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <set_priority>:
.global set_priority
set_priority:
 li a7, SYS_set_priority
 402:	48e1                	li	a7,24
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 40a:	1101                	add	sp,sp,-32
 40c:	ec06                	sd	ra,24(sp)
 40e:	e822                	sd	s0,16(sp)
 410:	1000                	add	s0,sp,32
 412:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 416:	4605                	li	a2,1
 418:	fef40593          	add	a1,s0,-17
 41c:	00000097          	auipc	ra,0x0
 420:	f56080e7          	jalr	-170(ra) # 372 <write>
}
 424:	60e2                	ld	ra,24(sp)
 426:	6442                	ld	s0,16(sp)
 428:	6105                	add	sp,sp,32
 42a:	8082                	ret

000000000000042c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 42c:	7139                	add	sp,sp,-64
 42e:	fc06                	sd	ra,56(sp)
 430:	f822                	sd	s0,48(sp)
 432:	f426                	sd	s1,40(sp)
 434:	f04a                	sd	s2,32(sp)
 436:	ec4e                	sd	s3,24(sp)
 438:	0080                	add	s0,sp,64
 43a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 43c:	c299                	beqz	a3,442 <printint+0x16>
 43e:	0805c963          	bltz	a1,4d0 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 442:	2581                	sext.w	a1,a1
  neg = 0;
 444:	4881                	li	a7,0
 446:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 44a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 44c:	2601                	sext.w	a2,a2
 44e:	00000517          	auipc	a0,0x0
 452:	4ba50513          	add	a0,a0,1210 # 908 <digits>
 456:	883a                	mv	a6,a4
 458:	2705                	addw	a4,a4,1
 45a:	02c5f7bb          	remuw	a5,a1,a2
 45e:	1782                	sll	a5,a5,0x20
 460:	9381                	srl	a5,a5,0x20
 462:	97aa                	add	a5,a5,a0
 464:	0007c783          	lbu	a5,0(a5)
 468:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 46c:	0005879b          	sext.w	a5,a1
 470:	02c5d5bb          	divuw	a1,a1,a2
 474:	0685                	add	a3,a3,1
 476:	fec7f0e3          	bgeu	a5,a2,456 <printint+0x2a>
  if(neg)
 47a:	00088c63          	beqz	a7,492 <printint+0x66>
    buf[i++] = '-';
 47e:	fd070793          	add	a5,a4,-48
 482:	00878733          	add	a4,a5,s0
 486:	02d00793          	li	a5,45
 48a:	fef70823          	sb	a5,-16(a4)
 48e:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 492:	02e05863          	blez	a4,4c2 <printint+0x96>
 496:	fc040793          	add	a5,s0,-64
 49a:	00e78933          	add	s2,a5,a4
 49e:	fff78993          	add	s3,a5,-1
 4a2:	99ba                	add	s3,s3,a4
 4a4:	377d                	addw	a4,a4,-1
 4a6:	1702                	sll	a4,a4,0x20
 4a8:	9301                	srl	a4,a4,0x20
 4aa:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4ae:	fff94583          	lbu	a1,-1(s2)
 4b2:	8526                	mv	a0,s1
 4b4:	00000097          	auipc	ra,0x0
 4b8:	f56080e7          	jalr	-170(ra) # 40a <putc>
  while(--i >= 0)
 4bc:	197d                	add	s2,s2,-1
 4be:	ff3918e3          	bne	s2,s3,4ae <printint+0x82>
}
 4c2:	70e2                	ld	ra,56(sp)
 4c4:	7442                	ld	s0,48(sp)
 4c6:	74a2                	ld	s1,40(sp)
 4c8:	7902                	ld	s2,32(sp)
 4ca:	69e2                	ld	s3,24(sp)
 4cc:	6121                	add	sp,sp,64
 4ce:	8082                	ret
    x = -xx;
 4d0:	40b005bb          	negw	a1,a1
    neg = 1;
 4d4:	4885                	li	a7,1
    x = -xx;
 4d6:	bf85                	j	446 <printint+0x1a>

00000000000004d8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4d8:	715d                	add	sp,sp,-80
 4da:	e486                	sd	ra,72(sp)
 4dc:	e0a2                	sd	s0,64(sp)
 4de:	fc26                	sd	s1,56(sp)
 4e0:	f84a                	sd	s2,48(sp)
 4e2:	f44e                	sd	s3,40(sp)
 4e4:	f052                	sd	s4,32(sp)
 4e6:	ec56                	sd	s5,24(sp)
 4e8:	e85a                	sd	s6,16(sp)
 4ea:	e45e                	sd	s7,8(sp)
 4ec:	e062                	sd	s8,0(sp)
 4ee:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4f0:	0005c903          	lbu	s2,0(a1)
 4f4:	18090c63          	beqz	s2,68c <vprintf+0x1b4>
 4f8:	8aaa                	mv	s5,a0
 4fa:	8bb2                	mv	s7,a2
 4fc:	00158493          	add	s1,a1,1
  state = 0;
 500:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 502:	02500a13          	li	s4,37
 506:	4b55                	li	s6,21
 508:	a839                	j	526 <vprintf+0x4e>
        putc(fd, c);
 50a:	85ca                	mv	a1,s2
 50c:	8556                	mv	a0,s5
 50e:	00000097          	auipc	ra,0x0
 512:	efc080e7          	jalr	-260(ra) # 40a <putc>
 516:	a019                	j	51c <vprintf+0x44>
    } else if(state == '%'){
 518:	01498d63          	beq	s3,s4,532 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 51c:	0485                	add	s1,s1,1
 51e:	fff4c903          	lbu	s2,-1(s1)
 522:	16090563          	beqz	s2,68c <vprintf+0x1b4>
    if(state == 0){
 526:	fe0999e3          	bnez	s3,518 <vprintf+0x40>
      if(c == '%'){
 52a:	ff4910e3          	bne	s2,s4,50a <vprintf+0x32>
        state = '%';
 52e:	89d2                	mv	s3,s4
 530:	b7f5                	j	51c <vprintf+0x44>
      if(c == 'd'){
 532:	13490263          	beq	s2,s4,656 <vprintf+0x17e>
 536:	f9d9079b          	addw	a5,s2,-99
 53a:	0ff7f793          	zext.b	a5,a5
 53e:	12fb6563          	bltu	s6,a5,668 <vprintf+0x190>
 542:	f9d9079b          	addw	a5,s2,-99
 546:	0ff7f713          	zext.b	a4,a5
 54a:	10eb6f63          	bltu	s6,a4,668 <vprintf+0x190>
 54e:	00271793          	sll	a5,a4,0x2
 552:	00000717          	auipc	a4,0x0
 556:	35e70713          	add	a4,a4,862 # 8b0 <malloc+0x126>
 55a:	97ba                	add	a5,a5,a4
 55c:	439c                	lw	a5,0(a5)
 55e:	97ba                	add	a5,a5,a4
 560:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 562:	008b8913          	add	s2,s7,8
 566:	4685                	li	a3,1
 568:	4629                	li	a2,10
 56a:	000ba583          	lw	a1,0(s7)
 56e:	8556                	mv	a0,s5
 570:	00000097          	auipc	ra,0x0
 574:	ebc080e7          	jalr	-324(ra) # 42c <printint>
 578:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 57a:	4981                	li	s3,0
 57c:	b745                	j	51c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 57e:	008b8913          	add	s2,s7,8
 582:	4681                	li	a3,0
 584:	4629                	li	a2,10
 586:	000ba583          	lw	a1,0(s7)
 58a:	8556                	mv	a0,s5
 58c:	00000097          	auipc	ra,0x0
 590:	ea0080e7          	jalr	-352(ra) # 42c <printint>
 594:	8bca                	mv	s7,s2
      state = 0;
 596:	4981                	li	s3,0
 598:	b751                	j	51c <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 59a:	008b8913          	add	s2,s7,8
 59e:	4681                	li	a3,0
 5a0:	4641                	li	a2,16
 5a2:	000ba583          	lw	a1,0(s7)
 5a6:	8556                	mv	a0,s5
 5a8:	00000097          	auipc	ra,0x0
 5ac:	e84080e7          	jalr	-380(ra) # 42c <printint>
 5b0:	8bca                	mv	s7,s2
      state = 0;
 5b2:	4981                	li	s3,0
 5b4:	b7a5                	j	51c <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 5b6:	008b8c13          	add	s8,s7,8
 5ba:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5be:	03000593          	li	a1,48
 5c2:	8556                	mv	a0,s5
 5c4:	00000097          	auipc	ra,0x0
 5c8:	e46080e7          	jalr	-442(ra) # 40a <putc>
  putc(fd, 'x');
 5cc:	07800593          	li	a1,120
 5d0:	8556                	mv	a0,s5
 5d2:	00000097          	auipc	ra,0x0
 5d6:	e38080e7          	jalr	-456(ra) # 40a <putc>
 5da:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5dc:	00000b97          	auipc	s7,0x0
 5e0:	32cb8b93          	add	s7,s7,812 # 908 <digits>
 5e4:	03c9d793          	srl	a5,s3,0x3c
 5e8:	97de                	add	a5,a5,s7
 5ea:	0007c583          	lbu	a1,0(a5)
 5ee:	8556                	mv	a0,s5
 5f0:	00000097          	auipc	ra,0x0
 5f4:	e1a080e7          	jalr	-486(ra) # 40a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5f8:	0992                	sll	s3,s3,0x4
 5fa:	397d                	addw	s2,s2,-1
 5fc:	fe0914e3          	bnez	s2,5e4 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 600:	8be2                	mv	s7,s8
      state = 0;
 602:	4981                	li	s3,0
 604:	bf21                	j	51c <vprintf+0x44>
        s = va_arg(ap, char*);
 606:	008b8993          	add	s3,s7,8
 60a:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 60e:	02090163          	beqz	s2,630 <vprintf+0x158>
        while(*s != 0){
 612:	00094583          	lbu	a1,0(s2)
 616:	c9a5                	beqz	a1,686 <vprintf+0x1ae>
          putc(fd, *s);
 618:	8556                	mv	a0,s5
 61a:	00000097          	auipc	ra,0x0
 61e:	df0080e7          	jalr	-528(ra) # 40a <putc>
          s++;
 622:	0905                	add	s2,s2,1
        while(*s != 0){
 624:	00094583          	lbu	a1,0(s2)
 628:	f9e5                	bnez	a1,618 <vprintf+0x140>
        s = va_arg(ap, char*);
 62a:	8bce                	mv	s7,s3
      state = 0;
 62c:	4981                	li	s3,0
 62e:	b5fd                	j	51c <vprintf+0x44>
          s = "(null)";
 630:	00000917          	auipc	s2,0x0
 634:	27890913          	add	s2,s2,632 # 8a8 <malloc+0x11e>
        while(*s != 0){
 638:	02800593          	li	a1,40
 63c:	bff1                	j	618 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 63e:	008b8913          	add	s2,s7,8
 642:	000bc583          	lbu	a1,0(s7)
 646:	8556                	mv	a0,s5
 648:	00000097          	auipc	ra,0x0
 64c:	dc2080e7          	jalr	-574(ra) # 40a <putc>
 650:	8bca                	mv	s7,s2
      state = 0;
 652:	4981                	li	s3,0
 654:	b5e1                	j	51c <vprintf+0x44>
        putc(fd, c);
 656:	02500593          	li	a1,37
 65a:	8556                	mv	a0,s5
 65c:	00000097          	auipc	ra,0x0
 660:	dae080e7          	jalr	-594(ra) # 40a <putc>
      state = 0;
 664:	4981                	li	s3,0
 666:	bd5d                	j	51c <vprintf+0x44>
        putc(fd, '%');
 668:	02500593          	li	a1,37
 66c:	8556                	mv	a0,s5
 66e:	00000097          	auipc	ra,0x0
 672:	d9c080e7          	jalr	-612(ra) # 40a <putc>
        putc(fd, c);
 676:	85ca                	mv	a1,s2
 678:	8556                	mv	a0,s5
 67a:	00000097          	auipc	ra,0x0
 67e:	d90080e7          	jalr	-624(ra) # 40a <putc>
      state = 0;
 682:	4981                	li	s3,0
 684:	bd61                	j	51c <vprintf+0x44>
        s = va_arg(ap, char*);
 686:	8bce                	mv	s7,s3
      state = 0;
 688:	4981                	li	s3,0
 68a:	bd49                	j	51c <vprintf+0x44>
    }
  }
}
 68c:	60a6                	ld	ra,72(sp)
 68e:	6406                	ld	s0,64(sp)
 690:	74e2                	ld	s1,56(sp)
 692:	7942                	ld	s2,48(sp)
 694:	79a2                	ld	s3,40(sp)
 696:	7a02                	ld	s4,32(sp)
 698:	6ae2                	ld	s5,24(sp)
 69a:	6b42                	ld	s6,16(sp)
 69c:	6ba2                	ld	s7,8(sp)
 69e:	6c02                	ld	s8,0(sp)
 6a0:	6161                	add	sp,sp,80
 6a2:	8082                	ret

00000000000006a4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6a4:	715d                	add	sp,sp,-80
 6a6:	ec06                	sd	ra,24(sp)
 6a8:	e822                	sd	s0,16(sp)
 6aa:	1000                	add	s0,sp,32
 6ac:	e010                	sd	a2,0(s0)
 6ae:	e414                	sd	a3,8(s0)
 6b0:	e818                	sd	a4,16(s0)
 6b2:	ec1c                	sd	a5,24(s0)
 6b4:	03043023          	sd	a6,32(s0)
 6b8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6bc:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6c0:	8622                	mv	a2,s0
 6c2:	00000097          	auipc	ra,0x0
 6c6:	e16080e7          	jalr	-490(ra) # 4d8 <vprintf>
}
 6ca:	60e2                	ld	ra,24(sp)
 6cc:	6442                	ld	s0,16(sp)
 6ce:	6161                	add	sp,sp,80
 6d0:	8082                	ret

00000000000006d2 <printf>:

void
printf(const char *fmt, ...)
{
 6d2:	711d                	add	sp,sp,-96
 6d4:	ec06                	sd	ra,24(sp)
 6d6:	e822                	sd	s0,16(sp)
 6d8:	1000                	add	s0,sp,32
 6da:	e40c                	sd	a1,8(s0)
 6dc:	e810                	sd	a2,16(s0)
 6de:	ec14                	sd	a3,24(s0)
 6e0:	f018                	sd	a4,32(s0)
 6e2:	f41c                	sd	a5,40(s0)
 6e4:	03043823          	sd	a6,48(s0)
 6e8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6ec:	00840613          	add	a2,s0,8
 6f0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6f4:	85aa                	mv	a1,a0
 6f6:	4505                	li	a0,1
 6f8:	00000097          	auipc	ra,0x0
 6fc:	de0080e7          	jalr	-544(ra) # 4d8 <vprintf>
}
 700:	60e2                	ld	ra,24(sp)
 702:	6442                	ld	s0,16(sp)
 704:	6125                	add	sp,sp,96
 706:	8082                	ret

0000000000000708 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 708:	1141                	add	sp,sp,-16
 70a:	e422                	sd	s0,8(sp)
 70c:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 70e:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 712:	00001797          	auipc	a5,0x1
 716:	8ee7b783          	ld	a5,-1810(a5) # 1000 <freep>
 71a:	a02d                	j	744 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 71c:	4618                	lw	a4,8(a2)
 71e:	9f2d                	addw	a4,a4,a1
 720:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 724:	6398                	ld	a4,0(a5)
 726:	6310                	ld	a2,0(a4)
 728:	a83d                	j	766 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 72a:	ff852703          	lw	a4,-8(a0)
 72e:	9f31                	addw	a4,a4,a2
 730:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 732:	ff053683          	ld	a3,-16(a0)
 736:	a091                	j	77a <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 738:	6398                	ld	a4,0(a5)
 73a:	00e7e463          	bltu	a5,a4,742 <free+0x3a>
 73e:	00e6ea63          	bltu	a3,a4,752 <free+0x4a>
{
 742:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 744:	fed7fae3          	bgeu	a5,a3,738 <free+0x30>
 748:	6398                	ld	a4,0(a5)
 74a:	00e6e463          	bltu	a3,a4,752 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 74e:	fee7eae3          	bltu	a5,a4,742 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 752:	ff852583          	lw	a1,-8(a0)
 756:	6390                	ld	a2,0(a5)
 758:	02059813          	sll	a6,a1,0x20
 75c:	01c85713          	srl	a4,a6,0x1c
 760:	9736                	add	a4,a4,a3
 762:	fae60de3          	beq	a2,a4,71c <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 766:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 76a:	4790                	lw	a2,8(a5)
 76c:	02061593          	sll	a1,a2,0x20
 770:	01c5d713          	srl	a4,a1,0x1c
 774:	973e                	add	a4,a4,a5
 776:	fae68ae3          	beq	a3,a4,72a <free+0x22>
    p->s.ptr = bp->s.ptr;
 77a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 77c:	00001717          	auipc	a4,0x1
 780:	88f73223          	sd	a5,-1916(a4) # 1000 <freep>
}
 784:	6422                	ld	s0,8(sp)
 786:	0141                	add	sp,sp,16
 788:	8082                	ret

000000000000078a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 78a:	7139                	add	sp,sp,-64
 78c:	fc06                	sd	ra,56(sp)
 78e:	f822                	sd	s0,48(sp)
 790:	f426                	sd	s1,40(sp)
 792:	f04a                	sd	s2,32(sp)
 794:	ec4e                	sd	s3,24(sp)
 796:	e852                	sd	s4,16(sp)
 798:	e456                	sd	s5,8(sp)
 79a:	e05a                	sd	s6,0(sp)
 79c:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 79e:	02051493          	sll	s1,a0,0x20
 7a2:	9081                	srl	s1,s1,0x20
 7a4:	04bd                	add	s1,s1,15
 7a6:	8091                	srl	s1,s1,0x4
 7a8:	0014899b          	addw	s3,s1,1
 7ac:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 7ae:	00001517          	auipc	a0,0x1
 7b2:	85253503          	ld	a0,-1966(a0) # 1000 <freep>
 7b6:	c515                	beqz	a0,7e2 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7b8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7ba:	4798                	lw	a4,8(a5)
 7bc:	02977f63          	bgeu	a4,s1,7fa <malloc+0x70>
  if(nu < 4096)
 7c0:	8a4e                	mv	s4,s3
 7c2:	0009871b          	sext.w	a4,s3
 7c6:	6685                	lui	a3,0x1
 7c8:	00d77363          	bgeu	a4,a3,7ce <malloc+0x44>
 7cc:	6a05                	lui	s4,0x1
 7ce:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7d2:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7d6:	00001917          	auipc	s2,0x1
 7da:	82a90913          	add	s2,s2,-2006 # 1000 <freep>
  if(p == (char*)-1)
 7de:	5afd                	li	s5,-1
 7e0:	a895                	j	854 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 7e2:	00001797          	auipc	a5,0x1
 7e6:	82e78793          	add	a5,a5,-2002 # 1010 <base>
 7ea:	00001717          	auipc	a4,0x1
 7ee:	80f73b23          	sd	a5,-2026(a4) # 1000 <freep>
 7f2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7f4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7f8:	b7e1                	j	7c0 <malloc+0x36>
      if(p->s.size == nunits)
 7fa:	02e48c63          	beq	s1,a4,832 <malloc+0xa8>
        p->s.size -= nunits;
 7fe:	4137073b          	subw	a4,a4,s3
 802:	c798                	sw	a4,8(a5)
        p += p->s.size;
 804:	02071693          	sll	a3,a4,0x20
 808:	01c6d713          	srl	a4,a3,0x1c
 80c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 80e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 812:	00000717          	auipc	a4,0x0
 816:	7ea73723          	sd	a0,2030(a4) # 1000 <freep>
      return (void*)(p + 1);
 81a:	01078513          	add	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 81e:	70e2                	ld	ra,56(sp)
 820:	7442                	ld	s0,48(sp)
 822:	74a2                	ld	s1,40(sp)
 824:	7902                	ld	s2,32(sp)
 826:	69e2                	ld	s3,24(sp)
 828:	6a42                	ld	s4,16(sp)
 82a:	6aa2                	ld	s5,8(sp)
 82c:	6b02                	ld	s6,0(sp)
 82e:	6121                	add	sp,sp,64
 830:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 832:	6398                	ld	a4,0(a5)
 834:	e118                	sd	a4,0(a0)
 836:	bff1                	j	812 <malloc+0x88>
  hp->s.size = nu;
 838:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 83c:	0541                	add	a0,a0,16
 83e:	00000097          	auipc	ra,0x0
 842:	eca080e7          	jalr	-310(ra) # 708 <free>
  return freep;
 846:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 84a:	d971                	beqz	a0,81e <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 84c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 84e:	4798                	lw	a4,8(a5)
 850:	fa9775e3          	bgeu	a4,s1,7fa <malloc+0x70>
    if(p == freep)
 854:	00093703          	ld	a4,0(s2)
 858:	853e                	mv	a0,a5
 85a:	fef719e3          	bne	a4,a5,84c <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 85e:	8552                	mv	a0,s4
 860:	00000097          	auipc	ra,0x0
 864:	b7a080e7          	jalr	-1158(ra) # 3da <sbrk>
  if(p == (char*)-1)
 868:	fd5518e3          	bne	a0,s5,838 <malloc+0xae>
        return 0;
 86c:	4501                	li	a0,0
 86e:	bf45                	j	81e <malloc+0x94>
