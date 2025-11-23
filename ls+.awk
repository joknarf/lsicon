# ls+.awk
# Author: joknarf

function print_multic() {
# multicolumn output
  bestC=1; pad=2; width=TERMW
  # Max nb columns
  Cmax=1+int((width-maxw)/(minw+pad))
  if (Cmax<1) Cmax=1
  if (Cmax>n) Cmax=n
  if (flag_1) Cmax=1
  colw[1]=0
  # Try possible column counts
  for (C=Cmax;C>=1;C--) {
    R=int((n+C-1)/C)
    if (C==1) { bestC=1; break }
    delete colw
    # per-column width
    for (i=1;i<=n;i++) {
      c=int((i-1)/R)+1
      if (vlen_a[i] > colw[c]) colw[c]=vlen_a[i]
    }
    # total width
    total=0
    for (c=1;c<=C;c++) {
      total+=colw[c]
      if (total>width) break
      if (c<C) total+=pad
    }
    if (total<=width) { bestC=C; break }
  }
  # 1 col trivial print
  if (bestC==1) {
    for (i=1;i<=n;i++) print short_a[i]
    return
  }
  C=bestC
  # print rows
  for (r=1;r<=R;r++) {
    for (c=1;c<=C;c++) {
      i=(c-1)*R+r
      if (i>n) break
      if (c<C) spaces=colw[c]-vlen_a[i]+pad
      else spaces=0
      printf("%s%*s", short_a[i], spaces, "")
    }
    printf("\n")
  }
}
function print_long() {
  if (total_line) print total_line
  total_line=""
  for (i=1;i<=n;i++) {
    if (name_a[i]=="" || long_a[i]=="") continue
    if (flag_i) printf("%s%*s ", colors[C_INUM], max_inums, inums_a[i])
    if (flag_s) printf("%s%*s ", colors[C_SIZE], max_size, sizeb_a[i])
    col=cols_a[i]
    lcol="l" col
    perms=perms_a[i]
    perms_type=substr(perms,1,1)
    perms_owner=substr(perms,2,3)
    perms_group=substr(perms,5,3)
    perms_other=substr(perms,8,3)
    perms_acl=substr(perms,11,1)
    if (perms_acl=="") perms_acl=" "
    if (USER==owner_a[i]) {
      c_perms_owner=colors[lcol]
      c_owner=colors["l" C_USER]
    } else {
      c_perms_owner=colors[col]
      c_owner=colors[C_USER]
    }
    if (group_a[i] in user_groups) {
      c_perms_group=colors[lcol]
      c_group=colors["l" C_USER]
    } else {
      c_perms_group=colors[col]
      c_group=colors[C_USER]
    }
    perms=colors[lcol] perms_type RESET c_perms_owner perms_owner c_perms_group perms_group colors[lcol] perms_other perms_acl
    printf("%s ", perms)
    if (!(flag_g)) printf("%s%-*s ", c_owner, max_owner, owner_a[i])
    if (!(flag_G)) printf("%s%-*s ", c_group, max_group, group_a[i])
    if (flag_Z) printf(" %s%*s", colors[C_CONTEXT], max_context,context_a[i])
    printf(" %s%*s %s %s\n", colors[C_SIZE], max_size, size_a[i], colors[C_DATE] date_a[i], long_a[i])
  }
}
function fgcol(num) {
  return ESC num "m"
}
function fglcol(num) {
  return ESC num+60 "m"
}
function print_ls() {
  if (flag_l) print_long()
  else print_multic()
  n=0; max_links=0; max_owner=0; max_group=0; max_size=0; max_inums=0; maxw=0;
}
BEGIN {
  ESC="\033["
  split(GROUPS, user_groups)
  for(i in user_groups) user_groups[user_groups[i]]=1
  split(FLAGS, f)
  for(i in f) flags[f[i]]=1
  flag_i=("i" in flags)
  flag_s=("s" in flags)
  flag_Z=("Z" in flags)
  flag_l=("l" in flags)
  flag_g=("g" in flags)
  flag_G=("G" in flags)
  flag_1=("1" in flags)
  while ((getline < iconfile) > 0)
    for(i=2;i<=NF;i++) I_EXT[$i]=$1
  close(iconfile)
  while ((getline < colorfile) > 0)
    for(i=2;i<=NF;i++) C_EXT[$i]=$1
  close(colorfile)
  # basic colors
  split("black,red,green,yellow,blue,magenta,cyan,white", colors, ",")
  for(i=1;i<=8;i++) {
    colors[colors[i]]=fgcol(i+29)
    colors["l"colors[i]]=fglcol(i+29)
  }
  # theme colors
  while ((getline < themefile) > 0)
    if (NF==2) {
      colors[$1]=ESC "38;2;" $2 "m"
      colors[$1"_bg"]=ESC "48;2;" $2 "m" ESC"38;2;235;235;235m" ESC"5m" # blink for mising
    }
  RESET=ESC "0m"
  C_DATE=C_EXT["date"]
  C_USER=C_EXT["user"]
  C_SIZE=C_EXT["size"]
  C_CONTEXT=C_EXT["context"]
  C_INUM=C_EXT["inum"]
  C_TYPE["-"]=C_EXT["file"]
  C_TYPE["d"]=C_EXT["folder"]
  C_TYPE["p"]=C_EXT["pipe"]
  C_TYPE["s"]=C_EXT["socket"]
  C_TYPE["l"]=C_EXT["symlink"]
  C_TYPE["x"]=C_EXT["exec"]
  C_TYPE["b"]=C_EXT["blockdev"]
  C_TYPE["c"]=C_EXT["chardev"]
  I_TYPE["-"]=I_EXT["file"]
  I_TYPE["d"]=I_EXT["folder"]
  I_TYPE["l"]=I_EXT["symlink"]
  I_TYPE["p"]=I_EXT["pipe"]
  I_TYPE["s"]=I_EXT["socket"]
  I_TYPE["x"]=I_EXT["exec"]
  I_TYPE["b"]=I_EXT["blockdev"]
  I_TYPE["c"]=I_EXT["chardev"]
  C_IND["|"]=C_EXT["pipe"]
  C_IND["="]=C_EXT["socket"]
  C_IND["*"]=C_EXT["exec"]
  C_IND["/"]=C_EXT["folder"]
  C_IND[">"]=C_EXT["door"]
  C_IND["?"]=C_EXT["missing"] # not implemented in ls
}
# handle ls error messages
/^(ls|gls):/ { print_ls();print colors["lred"] $0 RESET >"/dev/stderr"; next }
/^"/{ gsub(/^"|\\|":$/,""); print $0":"; next }
$0=="" { print_ls(); print ""; next }
/^total / { total_line=$0; next }
{
  if (/\x1b\[1m/) missing=1; else missing=0
  gsub(/^ +|\x1b\[1?[mK]/, "") # leading spaces/ANSI codes
}
{
  c=1
  if (flag_i) inum=$(c++)
  if (flag_s) sizeb=$(c++)
  perms=$(c++); links=$(c++); owner=$(c++); group=$(c++);
  if (flag_Z) context=$(c++)
  if (perms ~ /^c/ || perms ~ /^b/) size=$(c++)" "$(c++)
  else size=$(c++)
  date=$(c++) " " $(c++); fname=$(c++); target=$(c+1)
  type=substr(perms,1,1)
  c_link=C_TYPE["-"]
  file_i=substr($0, index($0, "\""))
  indicator=(substr(file_i,length(file_i)))
  if (indicator!="\"") file_i=substr(file_i, 1, length(file_i)-1)
  if (type=="l") {
    match(file_i, /^"(([^"\\]|\\.)*)"/, m1)
    fname=m1[1]
    file_i=substr(file_i,length(fname)+8)
    if(flag_l) {
      target=substr(file_i,1,length(file_i)-1)
      if (target ~ /\\\\/) {target=gensub(/\\([^\\])/, "\\1", "g", fname); gsub(/\\\\/,"\\",target)}
      else gsub(/\\/,"",target)
    }
  } else {
    fname=substr(file_i,2,length(file_i)-2)
    target=""
  }
  if (fname ~ /\\\\/) {fname=gensub(/\\([^\\])/, "\\1", "g", fname); gsub(/\\\\/,"\\",fname)} # real backslash
  else gsub(/\\/,"",fname) # litteral display

  if (type=="l") {
    if (missing) {
      c_link=C_IND["?"] "_bg"
    } else {
      if (indicator in C_IND) {
        c_link="l" C_IND[indicator]
      } else c_link="l" C_TYPE["-"]
    }
  }
  ext=""
  if (match(fname, /\.[^.]+$/, ex)) ext=tolower(ex[0])

  col=C_TYPE[type]
  icon=I_TYPE[type]
  if (type=="-") {
    if (index(perms, "x")>0) {
    col=C_TYPE["x"]
    icon=I_TYPE["x"]
    } else if (ext in C_EXT) col=C_EXT[ext]
    if (ext in I_EXT) icon=I_EXT[ext]
  }

  vlen=length(fname)+2
  lcol="l"col
  if (vlen>maxw) maxw=vlen
  if (n==1 || vlen < minw) minw=vlen
  display_name=fname
  if (target != "") display_name=display_name " -> " colors[c_link] target
  long=colors[lcol] icon " " display_name RESET
  if (missing && !flag_l) lcol=C_IND["?"] "_bg"
  short=colors[lcol] icon " " fname RESET

  if (length(inum)>max_inums) max_inums=length(inum)
  if (length(links)>max_links) max_links=length(links)
  if (length(owner)>max_owner) max_owner=length(owner)
  if (length(group)>max_group) max_group=length(group)
  if (length(size)>max_size) max_size=length(size)
  if (length(sizeb)>max_size) max_size=length(sizeb)
  if (length(context)>max_context) max_context=length(context)
  ++n
  inums_a[n]=inum; perms_a[n]=perms; links_a[n]=links; owner_a[n]=owner; group_a[n]=group; size_a[n]=size;
  date_a[n]=date; name_a[n]=fname; short_a[n]=short; long_a[n]=long; vlen_a[n]=vlen
  context_a[n]=context; sizeb_a[n]=sizeb
  cols_a[n]=col
}
END {
  if (flag_l) print_long()
  else print_multic()
}
