number_of_robots=$1
for i in $(scripts/range 1 $number_of_robots)
do
  echo './doit.rb 5 2 0.2> 'out$i' 2>&1'
done | scripts/parallel_run.pl $number_of_robots
