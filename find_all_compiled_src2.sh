
#p4 sync
rm start_time
touch start_time
build
find . -name \*.h -anewer start_time >dependence.txt
find . -name \*.c -anewer start_time >>dependence.txt
find . -name \*.cpp -anewer start_time >>dependence.txt

find . -name "*.h" -o -name "*.c" -anewer start_time

find . -name '*.[ch]' \
-o -name '*.java' \
-o -name '*properties' \
-o -name '*.cpp' \
-o -name '*.cc' \
-o -name '*.hpp' \
-o -name '*.py' \
-o -name '*.php' -anewer start_time > "code.text"
