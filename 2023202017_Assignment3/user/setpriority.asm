
user/_setpriority:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "user/user.h"
#include "kernel/fcntl.h"

int
main(int argc, char ** argv)
{
   0:	7179                	add	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	add	s0,sp,48
   e:	84ae                	mv	s1,a1
    int old_sp, new_sp, pid;

    if (argc != 3) {
  10:	478d                	li	a5,3
  12:	02f50163          	beq	a0,a5,34 <main+0x34>
        fprintf(2, "%s: execution failed - insufficient number of arguments\n", argv[0]);
  16:	6190                	ld	a2,0(a1)
  18:	00001597          	auipc	a1,0x1
  1c:	85858593          	add	a1,a1,-1960 # 870 <malloc+0xea>
  20:	4509                	li	a0,2
  22:	00000097          	auipc	ra,0x0
  26:	67e080e7          	jalr	1662(ra) # 6a0 <fprintf>
        exit(1);
  2a:	4505                	li	a0,1
  2c:	00000097          	auipc	ra,0x0
  30:	322080e7          	jalr	802(ra) # 34e <exit>
    }

    new_sp = atoi(argv[1]);
  34:	6588                	ld	a0,8(a1)
  36:	00000097          	auipc	ra,0x0
  3a:	21e080e7          	jalr	542(ra) # 254 <atoi>
  3e:	892a                	mv	s2,a0
    pid = atoi(argv[2]);
  40:	6888                	ld	a0,16(s1)
  42:	00000097          	auipc	ra,0x0
  46:	212080e7          	jalr	530(ra) # 254 <atoi>
  4a:	89aa                	mv	s3,a0

    if (new_sp < 0 || new_sp > 100) {
  4c:	0009071b          	sext.w	a4,s2
  50:	06400793          	li	a5,100
  54:	02e7f163          	bgeu	a5,a4,76 <main+0x76>
        fprintf(2, "%s: execution failed - static priority should be in the range 0-100\n", argv[0]);
  58:	6090                	ld	a2,0(s1)
  5a:	00001597          	auipc	a1,0x1
  5e:	85658593          	add	a1,a1,-1962 # 8b0 <malloc+0x12a>
  62:	4509                	li	a0,2
  64:	00000097          	auipc	ra,0x0
  68:	63c080e7          	jalr	1596(ra) # 6a0 <fprintf>
        exit(1);
  6c:	4505                	li	a0,1
  6e:	00000097          	auipc	ra,0x0
  72:	2e0080e7          	jalr	736(ra) # 34e <exit>
    }

    old_sp = set_priority(new_sp, pid);
  76:	85aa                	mv	a1,a0
  78:	854a                	mv	a0,s2
  7a:	00000097          	auipc	ra,0x0
  7e:	384080e7          	jalr	900(ra) # 3fe <set_priority>
  82:	86aa                	mv	a3,a0
    if (old_sp < 0) {
  84:	02054263          	bltz	a0,a8 <main+0xa8>
        fprintf(2, "%s: execution failed - no process with process ID %d exists\n", argv[0], pid);
        exit(1);
    }

    printf("%s: priority of process with ID %d successfully updated from %d to %d\n", argv[0], pid, old_sp, new_sp);
  88:	874a                	mv	a4,s2
  8a:	864e                	mv	a2,s3
  8c:	608c                	ld	a1,0(s1)
  8e:	00001517          	auipc	a0,0x1
  92:	8aa50513          	add	a0,a0,-1878 # 938 <malloc+0x1b2>
  96:	00000097          	auipc	ra,0x0
  9a:	638080e7          	jalr	1592(ra) # 6ce <printf>
    exit(0);
  9e:	4501                	li	a0,0
  a0:	00000097          	auipc	ra,0x0
  a4:	2ae080e7          	jalr	686(ra) # 34e <exit>
        fprintf(2, "%s: execution failed - no process with process ID %d exists\n", argv[0], pid);
  a8:	86ce                	mv	a3,s3
  aa:	6090                	ld	a2,0(s1)
  ac:	00001597          	auipc	a1,0x1
  b0:	84c58593          	add	a1,a1,-1972 # 8f8 <malloc+0x172>
  b4:	4509                	li	a0,2
  b6:	00000097          	auipc	ra,0x0
  ba:	5ea080e7          	jalr	1514(ra) # 6a0 <fprintf>
        exit(1);
  be:	4505                	li	a0,1
  c0:	00000097          	auipc	ra,0x0
  c4:	28e080e7          	jalr	654(ra) # 34e <exit>

00000000000000c8 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  c8:	1141                	add	sp,sp,-16
  ca:	e406                	sd	ra,8(sp)
  cc:	e022                	sd	s0,0(sp)
  ce:	0800                	add	s0,sp,16
  extern int main();
  main();
  d0:	00000097          	auipc	ra,0x0
  d4:	f30080e7          	jalr	-208(ra) # 0 <main>
  exit(0);
  d8:	4501                	li	a0,0
  da:	00000097          	auipc	ra,0x0
  de:	274080e7          	jalr	628(ra) # 34e <exit>

00000000000000e2 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  e2:	1141                	add	sp,sp,-16
  e4:	e422                	sd	s0,8(sp)
  e6:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  e8:	87aa                	mv	a5,a0
  ea:	0585                	add	a1,a1,1
  ec:	0785                	add	a5,a5,1
  ee:	fff5c703          	lbu	a4,-1(a1)
  f2:	fee78fa3          	sb	a4,-1(a5)
  f6:	fb75                	bnez	a4,ea <strcpy+0x8>
    ;
  return os;
}
  f8:	6422                	ld	s0,8(sp)
  fa:	0141                	add	sp,sp,16
  fc:	8082                	ret

00000000000000fe <strcmp>:

int
strcmp(const char *p, const char *q)
{
  fe:	1141                	add	sp,sp,-16
 100:	e422                	sd	s0,8(sp)
 102:	0800                	add	s0,sp,16
  while(*p && *p == *q)
 104:	00054783          	lbu	a5,0(a0)
 108:	cb91                	beqz	a5,11c <strcmp+0x1e>
 10a:	0005c703          	lbu	a4,0(a1)
 10e:	00f71763          	bne	a4,a5,11c <strcmp+0x1e>
    p++, q++;
 112:	0505                	add	a0,a0,1
 114:	0585                	add	a1,a1,1
  while(*p && *p == *q)
 116:	00054783          	lbu	a5,0(a0)
 11a:	fbe5                	bnez	a5,10a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 11c:	0005c503          	lbu	a0,0(a1)
}
 120:	40a7853b          	subw	a0,a5,a0
 124:	6422                	ld	s0,8(sp)
 126:	0141                	add	sp,sp,16
 128:	8082                	ret

000000000000012a <strlen>:

uint
strlen(const char *s)
{
 12a:	1141                	add	sp,sp,-16
 12c:	e422                	sd	s0,8(sp)
 12e:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 130:	00054783          	lbu	a5,0(a0)
 134:	cf91                	beqz	a5,150 <strlen+0x26>
 136:	0505                	add	a0,a0,1
 138:	87aa                	mv	a5,a0
 13a:	86be                	mv	a3,a5
 13c:	0785                	add	a5,a5,1
 13e:	fff7c703          	lbu	a4,-1(a5)
 142:	ff65                	bnez	a4,13a <strlen+0x10>
 144:	40a6853b          	subw	a0,a3,a0
 148:	2505                	addw	a0,a0,1
    ;
  return n;
}
 14a:	6422                	ld	s0,8(sp)
 14c:	0141                	add	sp,sp,16
 14e:	8082                	ret
  for(n = 0; s[n]; n++)
 150:	4501                	li	a0,0
 152:	bfe5                	j	14a <strlen+0x20>

0000000000000154 <memset>:

void*
memset(void *dst, int c, uint n)
{
 154:	1141                	add	sp,sp,-16
 156:	e422                	sd	s0,8(sp)
 158:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 15a:	ca19                	beqz	a2,170 <memset+0x1c>
 15c:	87aa                	mv	a5,a0
 15e:	1602                	sll	a2,a2,0x20
 160:	9201                	srl	a2,a2,0x20
 162:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 166:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 16a:	0785                	add	a5,a5,1
 16c:	fee79de3          	bne	a5,a4,166 <memset+0x12>
  }
  return dst;
}
 170:	6422                	ld	s0,8(sp)
 172:	0141                	add	sp,sp,16
 174:	8082                	ret

0000000000000176 <strchr>:

char*
strchr(const char *s, char c)
{
 176:	1141                	add	sp,sp,-16
 178:	e422                	sd	s0,8(sp)
 17a:	0800                	add	s0,sp,16
  for(; *s; s++)
 17c:	00054783          	lbu	a5,0(a0)
 180:	cb99                	beqz	a5,196 <strchr+0x20>
    if(*s == c)
 182:	00f58763          	beq	a1,a5,190 <strchr+0x1a>
  for(; *s; s++)
 186:	0505                	add	a0,a0,1
 188:	00054783          	lbu	a5,0(a0)
 18c:	fbfd                	bnez	a5,182 <strchr+0xc>
      return (char*)s;
  return 0;
 18e:	4501                	li	a0,0
}
 190:	6422                	ld	s0,8(sp)
 192:	0141                	add	sp,sp,16
 194:	8082                	ret
  return 0;
 196:	4501                	li	a0,0
 198:	bfe5                	j	190 <strchr+0x1a>

000000000000019a <gets>:

char*
gets(char *buf, int max)
{
 19a:	711d                	add	sp,sp,-96
 19c:	ec86                	sd	ra,88(sp)
 19e:	e8a2                	sd	s0,80(sp)
 1a0:	e4a6                	sd	s1,72(sp)
 1a2:	e0ca                	sd	s2,64(sp)
 1a4:	fc4e                	sd	s3,56(sp)
 1a6:	f852                	sd	s4,48(sp)
 1a8:	f456                	sd	s5,40(sp)
 1aa:	f05a                	sd	s6,32(sp)
 1ac:	ec5e                	sd	s7,24(sp)
 1ae:	1080                	add	s0,sp,96
 1b0:	8baa                	mv	s7,a0
 1b2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1b4:	892a                	mv	s2,a0
 1b6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1b8:	4aa9                	li	s5,10
 1ba:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1bc:	89a6                	mv	s3,s1
 1be:	2485                	addw	s1,s1,1
 1c0:	0344d863          	bge	s1,s4,1f0 <gets+0x56>
    cc = read(0, &c, 1);
 1c4:	4605                	li	a2,1
 1c6:	faf40593          	add	a1,s0,-81
 1ca:	4501                	li	a0,0
 1cc:	00000097          	auipc	ra,0x0
 1d0:	19a080e7          	jalr	410(ra) # 366 <read>
    if(cc < 1)
 1d4:	00a05e63          	blez	a0,1f0 <gets+0x56>
    buf[i++] = c;
 1d8:	faf44783          	lbu	a5,-81(s0)
 1dc:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1e0:	01578763          	beq	a5,s5,1ee <gets+0x54>
 1e4:	0905                	add	s2,s2,1
 1e6:	fd679be3          	bne	a5,s6,1bc <gets+0x22>
  for(i=0; i+1 < max; ){
 1ea:	89a6                	mv	s3,s1
 1ec:	a011                	j	1f0 <gets+0x56>
 1ee:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1f0:	99de                	add	s3,s3,s7
 1f2:	00098023          	sb	zero,0(s3)
  return buf;
}
 1f6:	855e                	mv	a0,s7
 1f8:	60e6                	ld	ra,88(sp)
 1fa:	6446                	ld	s0,80(sp)
 1fc:	64a6                	ld	s1,72(sp)
 1fe:	6906                	ld	s2,64(sp)
 200:	79e2                	ld	s3,56(sp)
 202:	7a42                	ld	s4,48(sp)
 204:	7aa2                	ld	s5,40(sp)
 206:	7b02                	ld	s6,32(sp)
 208:	6be2                	ld	s7,24(sp)
 20a:	6125                	add	sp,sp,96
 20c:	8082                	ret

000000000000020e <stat>:

int
stat(const char *n, struct stat *st)
{
 20e:	1101                	add	sp,sp,-32
 210:	ec06                	sd	ra,24(sp)
 212:	e822                	sd	s0,16(sp)
 214:	e426                	sd	s1,8(sp)
 216:	e04a                	sd	s2,0(sp)
 218:	1000                	add	s0,sp,32
 21a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 21c:	4581                	li	a1,0
 21e:	00000097          	auipc	ra,0x0
 222:	170080e7          	jalr	368(ra) # 38e <open>
  if(fd < 0)
 226:	02054563          	bltz	a0,250 <stat+0x42>
 22a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 22c:	85ca                	mv	a1,s2
 22e:	00000097          	auipc	ra,0x0
 232:	178080e7          	jalr	376(ra) # 3a6 <fstat>
 236:	892a                	mv	s2,a0
  close(fd);
 238:	8526                	mv	a0,s1
 23a:	00000097          	auipc	ra,0x0
 23e:	13c080e7          	jalr	316(ra) # 376 <close>
  return r;
}
 242:	854a                	mv	a0,s2
 244:	60e2                	ld	ra,24(sp)
 246:	6442                	ld	s0,16(sp)
 248:	64a2                	ld	s1,8(sp)
 24a:	6902                	ld	s2,0(sp)
 24c:	6105                	add	sp,sp,32
 24e:	8082                	ret
    return -1;
 250:	597d                	li	s2,-1
 252:	bfc5                	j	242 <stat+0x34>

0000000000000254 <atoi>:

int
atoi(const char *s)
{
 254:	1141                	add	sp,sp,-16
 256:	e422                	sd	s0,8(sp)
 258:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 25a:	00054683          	lbu	a3,0(a0)
 25e:	fd06879b          	addw	a5,a3,-48
 262:	0ff7f793          	zext.b	a5,a5
 266:	4625                	li	a2,9
 268:	02f66863          	bltu	a2,a5,298 <atoi+0x44>
 26c:	872a                	mv	a4,a0
  n = 0;
 26e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 270:	0705                	add	a4,a4,1
 272:	0025179b          	sllw	a5,a0,0x2
 276:	9fa9                	addw	a5,a5,a0
 278:	0017979b          	sllw	a5,a5,0x1
 27c:	9fb5                	addw	a5,a5,a3
 27e:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 282:	00074683          	lbu	a3,0(a4)
 286:	fd06879b          	addw	a5,a3,-48
 28a:	0ff7f793          	zext.b	a5,a5
 28e:	fef671e3          	bgeu	a2,a5,270 <atoi+0x1c>
  return n;
}
 292:	6422                	ld	s0,8(sp)
 294:	0141                	add	sp,sp,16
 296:	8082                	ret
  n = 0;
 298:	4501                	li	a0,0
 29a:	bfe5                	j	292 <atoi+0x3e>

000000000000029c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 29c:	1141                	add	sp,sp,-16
 29e:	e422                	sd	s0,8(sp)
 2a0:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2a2:	02b57463          	bgeu	a0,a1,2ca <memmove+0x2e>
    while(n-- > 0)
 2a6:	00c05f63          	blez	a2,2c4 <memmove+0x28>
 2aa:	1602                	sll	a2,a2,0x20
 2ac:	9201                	srl	a2,a2,0x20
 2ae:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2b2:	872a                	mv	a4,a0
      *dst++ = *src++;
 2b4:	0585                	add	a1,a1,1
 2b6:	0705                	add	a4,a4,1
 2b8:	fff5c683          	lbu	a3,-1(a1)
 2bc:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2c0:	fee79ae3          	bne	a5,a4,2b4 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2c4:	6422                	ld	s0,8(sp)
 2c6:	0141                	add	sp,sp,16
 2c8:	8082                	ret
    dst += n;
 2ca:	00c50733          	add	a4,a0,a2
    src += n;
 2ce:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2d0:	fec05ae3          	blez	a2,2c4 <memmove+0x28>
 2d4:	fff6079b          	addw	a5,a2,-1
 2d8:	1782                	sll	a5,a5,0x20
 2da:	9381                	srl	a5,a5,0x20
 2dc:	fff7c793          	not	a5,a5
 2e0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2e2:	15fd                	add	a1,a1,-1
 2e4:	177d                	add	a4,a4,-1
 2e6:	0005c683          	lbu	a3,0(a1)
 2ea:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2ee:	fee79ae3          	bne	a5,a4,2e2 <memmove+0x46>
 2f2:	bfc9                	j	2c4 <memmove+0x28>

00000000000002f4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2f4:	1141                	add	sp,sp,-16
 2f6:	e422                	sd	s0,8(sp)
 2f8:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2fa:	ca05                	beqz	a2,32a <memcmp+0x36>
 2fc:	fff6069b          	addw	a3,a2,-1
 300:	1682                	sll	a3,a3,0x20
 302:	9281                	srl	a3,a3,0x20
 304:	0685                	add	a3,a3,1
 306:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 308:	00054783          	lbu	a5,0(a0)
 30c:	0005c703          	lbu	a4,0(a1)
 310:	00e79863          	bne	a5,a4,320 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 314:	0505                	add	a0,a0,1
    p2++;
 316:	0585                	add	a1,a1,1
  while (n-- > 0) {
 318:	fed518e3          	bne	a0,a3,308 <memcmp+0x14>
  }
  return 0;
 31c:	4501                	li	a0,0
 31e:	a019                	j	324 <memcmp+0x30>
      return *p1 - *p2;
 320:	40e7853b          	subw	a0,a5,a4
}
 324:	6422                	ld	s0,8(sp)
 326:	0141                	add	sp,sp,16
 328:	8082                	ret
  return 0;
 32a:	4501                	li	a0,0
 32c:	bfe5                	j	324 <memcmp+0x30>

000000000000032e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 32e:	1141                	add	sp,sp,-16
 330:	e406                	sd	ra,8(sp)
 332:	e022                	sd	s0,0(sp)
 334:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 336:	00000097          	auipc	ra,0x0
 33a:	f66080e7          	jalr	-154(ra) # 29c <memmove>
}
 33e:	60a2                	ld	ra,8(sp)
 340:	6402                	ld	s0,0(sp)
 342:	0141                	add	sp,sp,16
 344:	8082                	ret

0000000000000346 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 346:	4885                	li	a7,1
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <exit>:
.global exit
exit:
 li a7, SYS_exit
 34e:	4889                	li	a7,2
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <wait>:
.global wait
wait:
 li a7, SYS_wait
 356:	488d                	li	a7,3
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 35e:	4891                	li	a7,4
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <read>:
.global read
read:
 li a7, SYS_read
 366:	4895                	li	a7,5
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <write>:
.global write
write:
 li a7, SYS_write
 36e:	48c1                	li	a7,16
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <close>:
.global close
close:
 li a7, SYS_close
 376:	48d5                	li	a7,21
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <kill>:
.global kill
kill:
 li a7, SYS_kill
 37e:	4899                	li	a7,6
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <exec>:
.global exec
exec:
 li a7, SYS_exec
 386:	489d                	li	a7,7
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <open>:
.global open
open:
 li a7, SYS_open
 38e:	48bd                	li	a7,15
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 396:	48c5                	li	a7,17
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 39e:	48c9                	li	a7,18
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3a6:	48a1                	li	a7,8
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <link>:
.global link
link:
 li a7, SYS_link
 3ae:	48cd                	li	a7,19
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3b6:	48d1                	li	a7,20
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3be:	48a5                	li	a7,9
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3c6:	48a9                	li	a7,10
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3ce:	48ad                	li	a7,11
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3d6:	48b1                	li	a7,12
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3de:	48b5                	li	a7,13
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3e6:	48b9                	li	a7,14
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <strace>:
.global strace
strace:
 li a7, SYS_strace
 3ee:	48d9                	li	a7,22
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 3f6:	48dd                	li	a7,23
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <set_priority>:
.global set_priority
set_priority:
 li a7, SYS_set_priority
 3fe:	48e1                	li	a7,24
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 406:	1101                	add	sp,sp,-32
 408:	ec06                	sd	ra,24(sp)
 40a:	e822                	sd	s0,16(sp)
 40c:	1000                	add	s0,sp,32
 40e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 412:	4605                	li	a2,1
 414:	fef40593          	add	a1,s0,-17
 418:	00000097          	auipc	ra,0x0
 41c:	f56080e7          	jalr	-170(ra) # 36e <write>
}
 420:	60e2                	ld	ra,24(sp)
 422:	6442                	ld	s0,16(sp)
 424:	6105                	add	sp,sp,32
 426:	8082                	ret

0000000000000428 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 428:	7139                	add	sp,sp,-64
 42a:	fc06                	sd	ra,56(sp)
 42c:	f822                	sd	s0,48(sp)
 42e:	f426                	sd	s1,40(sp)
 430:	f04a                	sd	s2,32(sp)
 432:	ec4e                	sd	s3,24(sp)
 434:	0080                	add	s0,sp,64
 436:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 438:	c299                	beqz	a3,43e <printint+0x16>
 43a:	0805c963          	bltz	a1,4cc <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 43e:	2581                	sext.w	a1,a1
  neg = 0;
 440:	4881                	li	a7,0
 442:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 446:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 448:	2601                	sext.w	a2,a2
 44a:	00000517          	auipc	a0,0x0
 44e:	59650513          	add	a0,a0,1430 # 9e0 <digits>
 452:	883a                	mv	a6,a4
 454:	2705                	addw	a4,a4,1
 456:	02c5f7bb          	remuw	a5,a1,a2
 45a:	1782                	sll	a5,a5,0x20
 45c:	9381                	srl	a5,a5,0x20
 45e:	97aa                	add	a5,a5,a0
 460:	0007c783          	lbu	a5,0(a5)
 464:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 468:	0005879b          	sext.w	a5,a1
 46c:	02c5d5bb          	divuw	a1,a1,a2
 470:	0685                	add	a3,a3,1
 472:	fec7f0e3          	bgeu	a5,a2,452 <printint+0x2a>
  if(neg)
 476:	00088c63          	beqz	a7,48e <printint+0x66>
    buf[i++] = '-';
 47a:	fd070793          	add	a5,a4,-48
 47e:	00878733          	add	a4,a5,s0
 482:	02d00793          	li	a5,45
 486:	fef70823          	sb	a5,-16(a4)
 48a:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 48e:	02e05863          	blez	a4,4be <printint+0x96>
 492:	fc040793          	add	a5,s0,-64
 496:	00e78933          	add	s2,a5,a4
 49a:	fff78993          	add	s3,a5,-1
 49e:	99ba                	add	s3,s3,a4
 4a0:	377d                	addw	a4,a4,-1
 4a2:	1702                	sll	a4,a4,0x20
 4a4:	9301                	srl	a4,a4,0x20
 4a6:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4aa:	fff94583          	lbu	a1,-1(s2)
 4ae:	8526                	mv	a0,s1
 4b0:	00000097          	auipc	ra,0x0
 4b4:	f56080e7          	jalr	-170(ra) # 406 <putc>
  while(--i >= 0)
 4b8:	197d                	add	s2,s2,-1
 4ba:	ff3918e3          	bne	s2,s3,4aa <printint+0x82>
}
 4be:	70e2                	ld	ra,56(sp)
 4c0:	7442                	ld	s0,48(sp)
 4c2:	74a2                	ld	s1,40(sp)
 4c4:	7902                	ld	s2,32(sp)
 4c6:	69e2                	ld	s3,24(sp)
 4c8:	6121                	add	sp,sp,64
 4ca:	8082                	ret
    x = -xx;
 4cc:	40b005bb          	negw	a1,a1
    neg = 1;
 4d0:	4885                	li	a7,1
    x = -xx;
 4d2:	bf85                	j	442 <printint+0x1a>

00000000000004d4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4d4:	715d                	add	sp,sp,-80
 4d6:	e486                	sd	ra,72(sp)
 4d8:	e0a2                	sd	s0,64(sp)
 4da:	fc26                	sd	s1,56(sp)
 4dc:	f84a                	sd	s2,48(sp)
 4de:	f44e                	sd	s3,40(sp)
 4e0:	f052                	sd	s4,32(sp)
 4e2:	ec56                	sd	s5,24(sp)
 4e4:	e85a                	sd	s6,16(sp)
 4e6:	e45e                	sd	s7,8(sp)
 4e8:	e062                	sd	s8,0(sp)
 4ea:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4ec:	0005c903          	lbu	s2,0(a1)
 4f0:	18090c63          	beqz	s2,688 <vprintf+0x1b4>
 4f4:	8aaa                	mv	s5,a0
 4f6:	8bb2                	mv	s7,a2
 4f8:	00158493          	add	s1,a1,1
  state = 0;
 4fc:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4fe:	02500a13          	li	s4,37
 502:	4b55                	li	s6,21
 504:	a839                	j	522 <vprintf+0x4e>
        putc(fd, c);
 506:	85ca                	mv	a1,s2
 508:	8556                	mv	a0,s5
 50a:	00000097          	auipc	ra,0x0
 50e:	efc080e7          	jalr	-260(ra) # 406 <putc>
 512:	a019                	j	518 <vprintf+0x44>
    } else if(state == '%'){
 514:	01498d63          	beq	s3,s4,52e <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 518:	0485                	add	s1,s1,1
 51a:	fff4c903          	lbu	s2,-1(s1)
 51e:	16090563          	beqz	s2,688 <vprintf+0x1b4>
    if(state == 0){
 522:	fe0999e3          	bnez	s3,514 <vprintf+0x40>
      if(c == '%'){
 526:	ff4910e3          	bne	s2,s4,506 <vprintf+0x32>
        state = '%';
 52a:	89d2                	mv	s3,s4
 52c:	b7f5                	j	518 <vprintf+0x44>
      if(c == 'd'){
 52e:	13490263          	beq	s2,s4,652 <vprintf+0x17e>
 532:	f9d9079b          	addw	a5,s2,-99
 536:	0ff7f793          	zext.b	a5,a5
 53a:	12fb6563          	bltu	s6,a5,664 <vprintf+0x190>
 53e:	f9d9079b          	addw	a5,s2,-99
 542:	0ff7f713          	zext.b	a4,a5
 546:	10eb6f63          	bltu	s6,a4,664 <vprintf+0x190>
 54a:	00271793          	sll	a5,a4,0x2
 54e:	00000717          	auipc	a4,0x0
 552:	43a70713          	add	a4,a4,1082 # 988 <malloc+0x202>
 556:	97ba                	add	a5,a5,a4
 558:	439c                	lw	a5,0(a5)
 55a:	97ba                	add	a5,a5,a4
 55c:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 55e:	008b8913          	add	s2,s7,8
 562:	4685                	li	a3,1
 564:	4629                	li	a2,10
 566:	000ba583          	lw	a1,0(s7)
 56a:	8556                	mv	a0,s5
 56c:	00000097          	auipc	ra,0x0
 570:	ebc080e7          	jalr	-324(ra) # 428 <printint>
 574:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 576:	4981                	li	s3,0
 578:	b745                	j	518 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 57a:	008b8913          	add	s2,s7,8
 57e:	4681                	li	a3,0
 580:	4629                	li	a2,10
 582:	000ba583          	lw	a1,0(s7)
 586:	8556                	mv	a0,s5
 588:	00000097          	auipc	ra,0x0
 58c:	ea0080e7          	jalr	-352(ra) # 428 <printint>
 590:	8bca                	mv	s7,s2
      state = 0;
 592:	4981                	li	s3,0
 594:	b751                	j	518 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 596:	008b8913          	add	s2,s7,8
 59a:	4681                	li	a3,0
 59c:	4641                	li	a2,16
 59e:	000ba583          	lw	a1,0(s7)
 5a2:	8556                	mv	a0,s5
 5a4:	00000097          	auipc	ra,0x0
 5a8:	e84080e7          	jalr	-380(ra) # 428 <printint>
 5ac:	8bca                	mv	s7,s2
      state = 0;
 5ae:	4981                	li	s3,0
 5b0:	b7a5                	j	518 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 5b2:	008b8c13          	add	s8,s7,8
 5b6:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5ba:	03000593          	li	a1,48
 5be:	8556                	mv	a0,s5
 5c0:	00000097          	auipc	ra,0x0
 5c4:	e46080e7          	jalr	-442(ra) # 406 <putc>
  putc(fd, 'x');
 5c8:	07800593          	li	a1,120
 5cc:	8556                	mv	a0,s5
 5ce:	00000097          	auipc	ra,0x0
 5d2:	e38080e7          	jalr	-456(ra) # 406 <putc>
 5d6:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5d8:	00000b97          	auipc	s7,0x0
 5dc:	408b8b93          	add	s7,s7,1032 # 9e0 <digits>
 5e0:	03c9d793          	srl	a5,s3,0x3c
 5e4:	97de                	add	a5,a5,s7
 5e6:	0007c583          	lbu	a1,0(a5)
 5ea:	8556                	mv	a0,s5
 5ec:	00000097          	auipc	ra,0x0
 5f0:	e1a080e7          	jalr	-486(ra) # 406 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5f4:	0992                	sll	s3,s3,0x4
 5f6:	397d                	addw	s2,s2,-1
 5f8:	fe0914e3          	bnez	s2,5e0 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 5fc:	8be2                	mv	s7,s8
      state = 0;
 5fe:	4981                	li	s3,0
 600:	bf21                	j	518 <vprintf+0x44>
        s = va_arg(ap, char*);
 602:	008b8993          	add	s3,s7,8
 606:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 60a:	02090163          	beqz	s2,62c <vprintf+0x158>
        while(*s != 0){
 60e:	00094583          	lbu	a1,0(s2)
 612:	c9a5                	beqz	a1,682 <vprintf+0x1ae>
          putc(fd, *s);
 614:	8556                	mv	a0,s5
 616:	00000097          	auipc	ra,0x0
 61a:	df0080e7          	jalr	-528(ra) # 406 <putc>
          s++;
 61e:	0905                	add	s2,s2,1
        while(*s != 0){
 620:	00094583          	lbu	a1,0(s2)
 624:	f9e5                	bnez	a1,614 <vprintf+0x140>
        s = va_arg(ap, char*);
 626:	8bce                	mv	s7,s3
      state = 0;
 628:	4981                	li	s3,0
 62a:	b5fd                	j	518 <vprintf+0x44>
          s = "(null)";
 62c:	00000917          	auipc	s2,0x0
 630:	35490913          	add	s2,s2,852 # 980 <malloc+0x1fa>
        while(*s != 0){
 634:	02800593          	li	a1,40
 638:	bff1                	j	614 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 63a:	008b8913          	add	s2,s7,8
 63e:	000bc583          	lbu	a1,0(s7)
 642:	8556                	mv	a0,s5
 644:	00000097          	auipc	ra,0x0
 648:	dc2080e7          	jalr	-574(ra) # 406 <putc>
 64c:	8bca                	mv	s7,s2
      state = 0;
 64e:	4981                	li	s3,0
 650:	b5e1                	j	518 <vprintf+0x44>
        putc(fd, c);
 652:	02500593          	li	a1,37
 656:	8556                	mv	a0,s5
 658:	00000097          	auipc	ra,0x0
 65c:	dae080e7          	jalr	-594(ra) # 406 <putc>
      state = 0;
 660:	4981                	li	s3,0
 662:	bd5d                	j	518 <vprintf+0x44>
        putc(fd, '%');
 664:	02500593          	li	a1,37
 668:	8556                	mv	a0,s5
 66a:	00000097          	auipc	ra,0x0
 66e:	d9c080e7          	jalr	-612(ra) # 406 <putc>
        putc(fd, c);
 672:	85ca                	mv	a1,s2
 674:	8556                	mv	a0,s5
 676:	00000097          	auipc	ra,0x0
 67a:	d90080e7          	jalr	-624(ra) # 406 <putc>
      state = 0;
 67e:	4981                	li	s3,0
 680:	bd61                	j	518 <vprintf+0x44>
        s = va_arg(ap, char*);
 682:	8bce                	mv	s7,s3
      state = 0;
 684:	4981                	li	s3,0
 686:	bd49                	j	518 <vprintf+0x44>
    }
  }
}
 688:	60a6                	ld	ra,72(sp)
 68a:	6406                	ld	s0,64(sp)
 68c:	74e2                	ld	s1,56(sp)
 68e:	7942                	ld	s2,48(sp)
 690:	79a2                	ld	s3,40(sp)
 692:	7a02                	ld	s4,32(sp)
 694:	6ae2                	ld	s5,24(sp)
 696:	6b42                	ld	s6,16(sp)
 698:	6ba2                	ld	s7,8(sp)
 69a:	6c02                	ld	s8,0(sp)
 69c:	6161                	add	sp,sp,80
 69e:	8082                	ret

00000000000006a0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6a0:	715d                	add	sp,sp,-80
 6a2:	ec06                	sd	ra,24(sp)
 6a4:	e822                	sd	s0,16(sp)
 6a6:	1000                	add	s0,sp,32
 6a8:	e010                	sd	a2,0(s0)
 6aa:	e414                	sd	a3,8(s0)
 6ac:	e818                	sd	a4,16(s0)
 6ae:	ec1c                	sd	a5,24(s0)
 6b0:	03043023          	sd	a6,32(s0)
 6b4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6b8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6bc:	8622                	mv	a2,s0
 6be:	00000097          	auipc	ra,0x0
 6c2:	e16080e7          	jalr	-490(ra) # 4d4 <vprintf>
}
 6c6:	60e2                	ld	ra,24(sp)
 6c8:	6442                	ld	s0,16(sp)
 6ca:	6161                	add	sp,sp,80
 6cc:	8082                	ret

00000000000006ce <printf>:

void
printf(const char *fmt, ...)
{
 6ce:	711d                	add	sp,sp,-96
 6d0:	ec06                	sd	ra,24(sp)
 6d2:	e822                	sd	s0,16(sp)
 6d4:	1000                	add	s0,sp,32
 6d6:	e40c                	sd	a1,8(s0)
 6d8:	e810                	sd	a2,16(s0)
 6da:	ec14                	sd	a3,24(s0)
 6dc:	f018                	sd	a4,32(s0)
 6de:	f41c                	sd	a5,40(s0)
 6e0:	03043823          	sd	a6,48(s0)
 6e4:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6e8:	00840613          	add	a2,s0,8
 6ec:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6f0:	85aa                	mv	a1,a0
 6f2:	4505                	li	a0,1
 6f4:	00000097          	auipc	ra,0x0
 6f8:	de0080e7          	jalr	-544(ra) # 4d4 <vprintf>
}
 6fc:	60e2                	ld	ra,24(sp)
 6fe:	6442                	ld	s0,16(sp)
 700:	6125                	add	sp,sp,96
 702:	8082                	ret

0000000000000704 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 704:	1141                	add	sp,sp,-16
 706:	e422                	sd	s0,8(sp)
 708:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 70a:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 70e:	00001797          	auipc	a5,0x1
 712:	8f27b783          	ld	a5,-1806(a5) # 1000 <freep>
 716:	a02d                	j	740 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 718:	4618                	lw	a4,8(a2)
 71a:	9f2d                	addw	a4,a4,a1
 71c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 720:	6398                	ld	a4,0(a5)
 722:	6310                	ld	a2,0(a4)
 724:	a83d                	j	762 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 726:	ff852703          	lw	a4,-8(a0)
 72a:	9f31                	addw	a4,a4,a2
 72c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 72e:	ff053683          	ld	a3,-16(a0)
 732:	a091                	j	776 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 734:	6398                	ld	a4,0(a5)
 736:	00e7e463          	bltu	a5,a4,73e <free+0x3a>
 73a:	00e6ea63          	bltu	a3,a4,74e <free+0x4a>
{
 73e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 740:	fed7fae3          	bgeu	a5,a3,734 <free+0x30>
 744:	6398                	ld	a4,0(a5)
 746:	00e6e463          	bltu	a3,a4,74e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 74a:	fee7eae3          	bltu	a5,a4,73e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 74e:	ff852583          	lw	a1,-8(a0)
 752:	6390                	ld	a2,0(a5)
 754:	02059813          	sll	a6,a1,0x20
 758:	01c85713          	srl	a4,a6,0x1c
 75c:	9736                	add	a4,a4,a3
 75e:	fae60de3          	beq	a2,a4,718 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 762:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 766:	4790                	lw	a2,8(a5)
 768:	02061593          	sll	a1,a2,0x20
 76c:	01c5d713          	srl	a4,a1,0x1c
 770:	973e                	add	a4,a4,a5
 772:	fae68ae3          	beq	a3,a4,726 <free+0x22>
    p->s.ptr = bp->s.ptr;
 776:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 778:	00001717          	auipc	a4,0x1
 77c:	88f73423          	sd	a5,-1912(a4) # 1000 <freep>
}
 780:	6422                	ld	s0,8(sp)
 782:	0141                	add	sp,sp,16
 784:	8082                	ret

0000000000000786 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 786:	7139                	add	sp,sp,-64
 788:	fc06                	sd	ra,56(sp)
 78a:	f822                	sd	s0,48(sp)
 78c:	f426                	sd	s1,40(sp)
 78e:	f04a                	sd	s2,32(sp)
 790:	ec4e                	sd	s3,24(sp)
 792:	e852                	sd	s4,16(sp)
 794:	e456                	sd	s5,8(sp)
 796:	e05a                	sd	s6,0(sp)
 798:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 79a:	02051493          	sll	s1,a0,0x20
 79e:	9081                	srl	s1,s1,0x20
 7a0:	04bd                	add	s1,s1,15
 7a2:	8091                	srl	s1,s1,0x4
 7a4:	0014899b          	addw	s3,s1,1
 7a8:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 7aa:	00001517          	auipc	a0,0x1
 7ae:	85653503          	ld	a0,-1962(a0) # 1000 <freep>
 7b2:	c515                	beqz	a0,7de <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7b4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7b6:	4798                	lw	a4,8(a5)
 7b8:	02977f63          	bgeu	a4,s1,7f6 <malloc+0x70>
  if(nu < 4096)
 7bc:	8a4e                	mv	s4,s3
 7be:	0009871b          	sext.w	a4,s3
 7c2:	6685                	lui	a3,0x1
 7c4:	00d77363          	bgeu	a4,a3,7ca <malloc+0x44>
 7c8:	6a05                	lui	s4,0x1
 7ca:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7ce:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7d2:	00001917          	auipc	s2,0x1
 7d6:	82e90913          	add	s2,s2,-2002 # 1000 <freep>
  if(p == (char*)-1)
 7da:	5afd                	li	s5,-1
 7dc:	a895                	j	850 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 7de:	00001797          	auipc	a5,0x1
 7e2:	83278793          	add	a5,a5,-1998 # 1010 <base>
 7e6:	00001717          	auipc	a4,0x1
 7ea:	80f73d23          	sd	a5,-2022(a4) # 1000 <freep>
 7ee:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7f0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7f4:	b7e1                	j	7bc <malloc+0x36>
      if(p->s.size == nunits)
 7f6:	02e48c63          	beq	s1,a4,82e <malloc+0xa8>
        p->s.size -= nunits;
 7fa:	4137073b          	subw	a4,a4,s3
 7fe:	c798                	sw	a4,8(a5)
        p += p->s.size;
 800:	02071693          	sll	a3,a4,0x20
 804:	01c6d713          	srl	a4,a3,0x1c
 808:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 80a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 80e:	00000717          	auipc	a4,0x0
 812:	7ea73923          	sd	a0,2034(a4) # 1000 <freep>
      return (void*)(p + 1);
 816:	01078513          	add	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 81a:	70e2                	ld	ra,56(sp)
 81c:	7442                	ld	s0,48(sp)
 81e:	74a2                	ld	s1,40(sp)
 820:	7902                	ld	s2,32(sp)
 822:	69e2                	ld	s3,24(sp)
 824:	6a42                	ld	s4,16(sp)
 826:	6aa2                	ld	s5,8(sp)
 828:	6b02                	ld	s6,0(sp)
 82a:	6121                	add	sp,sp,64
 82c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 82e:	6398                	ld	a4,0(a5)
 830:	e118                	sd	a4,0(a0)
 832:	bff1                	j	80e <malloc+0x88>
  hp->s.size = nu;
 834:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 838:	0541                	add	a0,a0,16
 83a:	00000097          	auipc	ra,0x0
 83e:	eca080e7          	jalr	-310(ra) # 704 <free>
  return freep;
 842:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 846:	d971                	beqz	a0,81a <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 848:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 84a:	4798                	lw	a4,8(a5)
 84c:	fa9775e3          	bgeu	a4,s1,7f6 <malloc+0x70>
    if(p == freep)
 850:	00093703          	ld	a4,0(s2)
 854:	853e                	mv	a0,a5
 856:	fef719e3          	bne	a4,a5,848 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 85a:	8552                	mv	a0,s4
 85c:	00000097          	auipc	ra,0x0
 860:	b7a080e7          	jalr	-1158(ra) # 3d6 <sbrk>
  if(p == (char*)-1)
 864:	fd5518e3          	bne	a0,s5,834 <malloc+0xae>
        return 0;
 868:	4501                	li	a0,0
 86a:	bf45                	j	81a <malloc+0x94>
