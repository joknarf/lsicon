function print_multic() {
# multicolumn output computation
    bestC = 1
    pad = 2
    width = TERMW
    # Upper bound for number of columns
    Cmax = 1 + int((width - maxw) / (minw + pad))
    if (Cmax < 1) Cmax = 1
    if (Cmax > n) Cmax = n
    if ("1" in flags) { Cmax=1 }
    colw[1] = 0
    # Try possible column counts from Cmax down to 1
    for (C = Cmax; C >= 1; C--) {
        R = int((n + C - 1) / C)
        if (C==1) {
          bestC=1
          break
        }
        # Compute per-column width
        for (c = 1; c <= C; c++) colw[c] = 0

        for (i = 1; i <= n; i++) {
            c = int((i-1) / R) + 1
            if (vlen_a[i] > colw[c]) colw[c] = vlen_a[i]
        }

        # Compute total width = sum(col widths) + padding
        total = 0
        for (c = 1; c <= C; c++) {
            total += colw[c]
            if (c < C) total += pad
        }

        if (total <= width) {
            bestC = C
            break      # largest possible C found → optimal
        }
    }
    # If only one column → trivial print, fastest path
    if (bestC == 1) {
        for (i = 1; i <= n; i++)
            print dec_short_a[i]
        return
    }
    C = bestC

    # print rows
    for (r = 1; r <= R; r++) {
        for (c = 1; c <= C; c++) {
            i = (c-1)*R + r
            if (i > n) break
            # padding if not last column
            if (c < C) spaces = colw[c] - vlen_a[i] + pad
            else spaces = 0
            printf("%s%*s", dec_short_a[i], spaces, "")
        }
        printf("\n")
    }
    fflush()
}
function print_long() {
    if (total_line) print total_line
    total_line = ""
    for (i=1;i<=n;i++) {
        if (name_a[i] == "" || dec_long_a[i] == "") continue
        if ("i" in flags)
           printf("%s%*s ", colors[COL_INUM], max_inums, inums_a[i])
        if ("s" in flags)
           printf("%s%*s ", colors[COL_SIZE], max_size, sizeb_a[i])
        col = cols_a[i]
        lcol = "l" col
        perms = perms_a[i]
        perms_type = substr(perms,1,1)
        perms_owner = substr(perms,2,3)
        perms_group = substr(perms,5,3)
        perms_other = substr(perms,8,3)
        perms_acl = substr(perms,11,1)
        if (perms_acl == "") perms_acl = " "
        if (USER==owner_a[i]) {
            col_perms_owner = colors[lcol]
            col_owner = colors["l" COL_USER]
        } else {
            col_perms_owner = colors[col]
            col_owner = colors[COL_USER]
        }
        if (group_a[i] in user_groups) {
            col_perms_group = colors[lcol]
            col_group = colors["l" COL_USER]
        } else {
            col_perms_group = colors[col]
            col_group = colors[COL_USER]
        }
        perms = colors[lcol] perms_type col_perms_owner perms_owner col_perms_group perms_group colors[lcol] perms_other perms_acl
        printf("%s ", perms) 
        if (!("g" in flags)) printf("%s%-*s ", col_owner, max_owner, owner_a[i])
        if (!("G" in flags)) printf("%s%-*s ", col_group, max_group, group_a[i])
        if ("Z" in flags)
            printf(" %s%*s", colors[COL_CONTEXT], max_context,context_a[i])
        printf(" %s%*s %s %s\n", colors[COL_SIZE], max_size, size_a[i], colors[COL_DATE] date_a[i], dec_long_a[i])
    }
}
function fgcol(num) {
    return ESC num "m"
}
function fglcol(num) {
    return ESC num+60 "m"
}
function print_ls() {
    if ("l" in flags) print_long()
    else print_multic()
    n=0; max_links=0; max_owner=0; max_group=0; max_size=0; max_inums=0; maxw=0;
}
BEGIN {
    ESC="\033["
    split(GROUPS, user_groups)
    for(i in user_groups) user_groups[user_groups[i]]=1
    split(FLAGS, f)
    for(i in f) flags[f[i]]=1
    while ((getline < iconfile) > 0)
        for(i=2;i<=NF;i++) EXT_ICON[$i]=$1
    close(iconfile)
    while ((getline < colorfile) > 0)
        for(i=2;i<=NF;i++) EXT_COLOR[$i]=$1
    close(colorfile)
    # initialize basic colors
    split("black,red,green,yellow,blue,magenta,cyan,white", colors, ",")
    for(i=1;i<=8;i++) {
         colors[colors[i]] = fgcol(i+29)
         colors["l"colors[i]] = fglcol(i+29)
    }
    # load theme colors
    while ((getline < themefile) > 0)
        if (NF==2)
            colors[$1]=ESC "38;2;" $2 "m"
    RESET=ESC "0m"
    COL_DATE=EXT_COLOR["date"]
    COL_USER=EXT_COLOR["user"]
    COL_SIZE=EXT_COLOR["size"]
    COL_CONTEXT=EXT_COLOR["context"]
    COL_INUM=EXT_COLOR["inum"]
    COL_TYPE["-"] = EXT_COLOR["file"]
    COL_TYPE["d"] = EXT_COLOR["folder"]
    COL_TYPE["p"] = EXT_COLOR["pipe"]
    COL_TYPE["s"] = EXT_COLOR["socket"]
    COL_TYPE["l"] = EXT_COLOR["symlink"]
    COL_TYPE["x"] = EXT_COLOR["exec"]
    COL_TYPE["b"] = EXT_COLOR["blockdev"]
    COL_TYPE["c"] = EXT_COLOR["chardev"]
    ICON_TYPE["-"] = EXT_ICON["file"]
    ICON_TYPE["d"] = EXT_ICON["folder"]
    ICON_TYPE["l"] = EXT_ICON["symlink"]
    ICON_TYPE["p"] = EXT_ICON["pipe"]
    ICON_TYPE["s"] = EXT_ICON["socket"]
    ICON_TYPE["x"] = EXT_ICON["exec"]
    ICON_TYPE["b"] = EXT_ICON["blockdev"]
    ICON_TYPE["c"] = EXT_ICON["chardev"]
    COL_CLASSIFY["|"] = EXT_COLOR["pipe"]
    COL_CLASSIFY["="] = EXT_COLOR["socket"]
    COL_CLASSIFY["*"] = EXT_COLOR["exec"]
    COL_CLASSIFY["/"] = EXT_COLOR["folder"]
    COL_CLASSIFY["?"] = EXT_COLOR["missing"] # not implemented in ls
    FS="\t"
    prevempty=0
    nr=1
}
# handle ls error messages
/^(ls|gls):/ { print_ls();print colors["lred"] $0 RESET >"/dev/stderr"; nr=1; next }
# gnu ls bug directory title line with not escaped spaces / best effort
nr==1 && /:$/ && !/\\ / && !/(^| )[dlsbpc-]([r-][w-][xSsTt-]){3}[ .]? +[0-9]+ / { gsub(/\\/,""); nr=0; print $0; next }
prevempty && /:$/ { gsub(/\\/,""); prevempty=0; print $0; next }
{ prevempty=0; nr=0 }
$0=="" { prevempty=1; print_ls(); print ""; next }
/^total / { total_line = $0; next }
{ # preprocess line to have tab field separator
    sub(/^ */, "")        # remove leading spaces
    gsub(/\\ /, "\\x20")  # protect escaped spaces (\ )
    gsub(/ +/, "\t")      # replace remaining (unescaped) spaces with tabs
    gsub(/\\x20/, " ")    # restore escaped spaces
    if (/\\\\/) {$0 = gensub(/\\([^\\])/, "\\1", "g"); gsub(/\\\\/,"\\")} # Keep real backslashes
    else gsub(/\\/,"")    # remove escape backslashes (litteral display)
}
{
    c = 1
    if ("i" in flags) inum=$(c++)
    if ("s" in flags) sizeb = $(c++);
    perms = $(c++); links = $(c++); owner = $(c++); group = $(c++);
    if ("Z" in flags) context=$(c++) 
    # special handling for /dev with xx, yy instead of size
    if (perms ~ /^c/ || perms ~ /^b/) size = $(c++)$(c++)
    else size = $(c++)
    date = $(c++) " " $(c++); fname=$(c++); target=$(c+1)
    file_type = substr(perms,1,1)
    col_link = COL_TYPE["-"]
    if (file_type=="l") {
        last_char = (substr(target,length(target)))
        if (last_char in COL_CLASSIFY) {
            sub(/.$/,"",target)
            col_link = COL_CLASSIFY[last_char]
        }
    } else if (substr(fname,length(fname)) in COL_CLASSIFY)
        sub(/.$/,"",fname)
    ext=""
    if (match(fname, /\.[^.]+$/, ex)) ext = tolower(ex[0])
    
    col = COL_TYPE[file_type]
    icon = ICON_TYPE[file_type]
    if (file_type=="-") {
        if (index(perms, "x") > 0) {
        col=COL_TYPE["x"]
        icon=ICON_TYPE["x"]
        } else if (ext in EXT_COLOR) col=EXT_COLOR[ext]
        if (ext in EXT_ICON) icon = EXT_ICON[ext]
    }
    

    vlen = length(fname) + 2
    if (vlen > maxw) maxw = vlen
    if (n==1 || vlen < minw) minw = vlen
    display_name = fname
    if (target != "") display_name = display_name " -> " colors["l"col_link] target
    dec_long = colors["l"col] icon " " display_name RESET
    dec_short = colors["l"col] icon " " fname RESET

    ++n
    if (length(inum) > max_inums) max_inums = length(inum)
    if (length(links) > max_links) max_links = length(links)
    if (length(owner) > max_owner) max_owner = length(owner)
    if (length(group) > max_group) max_group = length(group)
    if (length(size) > max_size) max_size = length(size)
    if (length(sizeb) > max_size) max_size = length(sizeb)
    if (length(context) > max_context) max_context = length(context)
    inums_a[n]=inum; perms_a[n]=perms; links_a[n]=links; owner_a[n]=owner; group_a[n]=group; size_a[n]=size;
    date_a[n]=date; name_a[n]=fname; dec_short_a[n]=dec_short; dec_long_a[n]=dec_long; vlen_a[n]=vlen
    context_a[n]=context; sizeb_a[n]=sizeb
    cols_a[n]=col
}

END {
    if ("l" in flags) print_long()
    else print_multic()
}
