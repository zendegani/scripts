#!/bin/sh

pfad=`XXXCAR_link-to-basename.sh $0 $1`
[ ! -e "$pfad" ] && echo "XXCAR error: $pfad" && exit

ID=`OUTCAR_ID.sh $pfad`  ## grept nach po.12345
[ "$ID" = "---" ] && echo --- && exit
#echo ID1:$ID pfad:$pfad

pfadnodeslist=`echo $pfad | sed 's|OUTCAR.*|nodeslist.'"$ID"'|'`
[ -e  "$pfadnodeslist" ] && cat $pfadnodeslist | xargs && exit

nodes=`qls.sh -r | grep $ID$ | awk '{print $1}' | uniq`

#echo OK: pfadnodeslist:$pfadnodeslist: nodes:$nodes:


[ ! -e "$pfadnodeslist" ] && [ "$nodes" != "" ] && echo $nodes | xargs -n 1 | tee -a $pfadnodeslist > /dev/null

[ "$nodes" != "" ] && echo $nodes 
[ "$nodes" = "" ] && echo ---
