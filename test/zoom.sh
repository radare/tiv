LINES=30
export $LINES
lim=$LINES
p=./tiv
img=$1
$p -nc $img
s=1
while : ; do
	$p -0s $s $img
	sleep 0.1
	s=$(($s+1))
	if [ "$s" -gt $lim ]; then
		break
	fi
done
