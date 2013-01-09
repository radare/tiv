img=$1
if [ -z "$img" ]; then
	echo "Use: $0 [imgfile]"
	exit 1
fi
p=./tiv
s=1
while : ; do
$p -a0 $img
sleep $s
$p -0 $img
sleep $s
$p -g0 $img
sleep $s
$p -n0 $img
sleep $s
done
