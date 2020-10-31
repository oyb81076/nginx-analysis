#!/usr/bin/env bash
SOURCE=$1
BUILD=`dirname $1`/build
TOMCAT=$BUILD/src.tomcat
URL=$BUILD/src.url
PATHNAME=$BUILD/src.pathname
PATHNAME_OUT_RATIO=$BUILD/out.pathname.ratio
PATHNAME_OUT_DURATION=$BUILD/out.pathname.duration
URL_OUT=$BUILD/out.url
IP=$BUILD/out.ip
mkdir -p $BUILD
echo "生成静态过滤文件 $TOMCAT"
cat $SOURCE | grep -v '"GET /assets' | grep -v '"GET /js/jsConfig' > $TOMCAT
echo "生成[耗时 url]文件 $URL"
cat $TOMCAT | awk '{if ($NF != "-")print $NF" "$7}' > $URL
echo "生成[耗时 pathname]文件 $PATHNAME"
cat $URL | awk -F'?' '{print $1}' | awk '{sub(/[0-9]{16}/,"");print}' | sort -rn > $PATHNAME
echo "生成[总耗时百分比 访问次数 平均耗时 pathname]文件 $PATHNAME_OUT_RATIO"
cat $PATHNAME | awk '
{
  count[$2]++;
  duration[$2]+= $1;
  total_duration += $1;
} END {
  for(url in count) {
    printf( "%7.2f %6s %7.3f %s\n", duration[url] / total_duration * 100, count[url], duration[url] / count[url], url)
  }
}' | sort -rn > $PATHNAME_OUT_RATIO
echo "生成[总耗时百分比 访问次数 平均耗时 pathname] sort by 平均耗时 $PATHNAME_OUT_DURATION"
cat $PATHNAME_OUT_RATIO | sort -rn -k 3 > $PATHNAME_OUT_DURATION

echo "生成[总耗时百分比 访问次数 平均耗时 url]文件 $URL_OUT"
cat $URL | awk '
{
  count[$2]++;
  duration[$2]+= $1;
  total_duration += $1;
} END {
  for(url in count) {
    printf( "%7.2f %6s %7.3f %s\n", duration[url] / total_duration * 100, count[url], duration[url] / count[url], url)
  }
}' | sort -rn > $URL_OUT
cat $SOURCE | awk '{ c[$1]++ }END{ for(ip in c) printf("%5s %s\n", c[ip], ip) }' | sort -rn > $IP

sed -i "" '1i\
总耗时\% 问次数 平均耗时 pathname
' $PATHNAME_OUT_DURATION
sed -i "" '1i\
总耗时\% 问次数 平均耗时 pathname
' $PATHNAME_OUT_RATIO
sed -i "" '1i\
总耗时\% 问次数 平均耗时 pathname
' $URL_OUT
