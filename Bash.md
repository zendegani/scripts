# Replace a newline (\n) using sed?
Ref:<a href="https://stackoverflow.com/users/11621/zsolt-botykai">@Zsolt Botykai</a>

To replace a newline "`\n`" with, _e.g._ space "` `" using the `sed` command:
```bash
sed 's/\n/ /g' file
```
would fail, because `sed` is intended to be used on line-based input.

There is a solution with [GNU `sed`](https://stackoverflow.com/questions/1251999/how-can-i-replace-a-newline-n-using-sed/1252010#1252010):

```bash
sed ':a;N;$!ba;s/\n/ /g' file
```

<p>This will read the whole file in a loop, then replaces the newline(s) with a space.</p>

<p>Explanation:</p>

<ol>
<li>Create a label via <code>:a</code>.</li>
<li>Append the current and next line to the pattern space via <code>N</code>.</li>
<li>If we are before the last line, branch to the created label <code>$!ba</code> (<code>$!</code> means not to do it on the last line as there should be one final newline).</li>
<li>Finally the substitution replaces every newline with a space on the pattern space (which is the whole file).</li>
</ol>

<p>Here is cross-platform compatible syntax which works with BSD and OS X's <code>sed</code> (as per <a href="https://stackoverflow.com/questions/1251999/how-can-i-replace-a-newline-n-using-sed?page=1&amp;tab=votes#comment9175314_1252191">@Benjie comment</a>):</p>

```sh
sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/ /g' file
```
<p>As you can see, using <code>sed</code> for this otherwise simple problem is problematic. For a simpler and adequate solution see <a href="https://stackoverflow.com/a/1252010/1638350">this answer</a>.</p>

# Split a string on a delimiter in Bash?
Ref:<a href="https://stackoverflow.com/users/34509/johannes-schaub-litb">@Johannes Schaub - litb</a>
<p>You can set the <a href="http://en.wikipedia.org/wiki/Internal_field_separator" rel="noreferrer">internal field separator</a> (IFS) variable, and then let it parse into an array. When this happens in a command, then the assignment to <code>IFS</code> only takes place to that single command's environment (to <code>read</code> ). It then parses the input according to the <code>IFS</code> variable value into an array, which we can then iterate over.</p>

```bash
IFS=';' read -ra ADDR <<< "$IN"
for i in "${ADDR[@]}"; do
    # process "$i"
done
```

<p>It will parse one line of items separated by <code>;</code>, pushing it into an array. Stuff for processing whole of <code>$IN</code>, each time one line of input separated by <code>;</code>:</p>

```bash
while IFS=';' read -ra ADDR; do
      for i in "${ADDR[@]}"; do
          # process "$i"
      done
done <<< "$IN"
```

# Remove the last line from a file in Bash
[[Ref.]](https://stackoverflow.com/questions/4881930/remove-the-last-line-from-a-file-in-bash)
<p>Using <a href="http://www.gnu.org/software/sed/" rel="noreferrer"><code>GNU sed</code></a>:</p>

```sh
sed -i '$ d' foo.txt
````

# Delete the first _n_ lines of an ascii file using shell commands.
[[Ref.]](https://unix.stackexchange.com/questions/37790/how-do-i-delete-the-first-n-lines-of-an-ascii-file-using-shell-commands)
<p>As long as the file is not a symlink or hardlink, you can use sed, tail, or awk. Example below.</p>

<pre><code>$ cat t.txt
12
34
56
78
90
</code></pre>

<h4>sed</h4>

<pre><code>$ sed -e '1,3d' &lt; t.txt
78
90
</code></pre>

<p>You can also use sed in-place without a temp file: <code>sed -i -e 1,3d yourfile</code>. This won't echo anything, it will just modify the file in-place. If you don't need to pipe the result to another command, this is easier.</p>

<h4>tail</h4>

<pre><code>$ tail -n +4 t.txt
78
90
</code></pre>

<h4>awk</h4>

<pre><code>$ awk 'NR &gt; 3 { print }' &lt; t.txt
78
90
</code></pre>

# Grep shows only words that match search pattern.
[[Ref.]](https://stackoverflow.com/questions/1546711/can-grep-show-only-words-that-match-search-pattern)

<p>Try grep -o</p>

```sh
grep -oh "\w*STRING\w*" *
```

<pre><code>-h, --no-filename
    Suppress the prefixing of file names on output. This is the default
    when there is only  one  file  (or only standard input) to search.
-o, --only-matching
    Print  only  the matched (non-empty) parts of a matching line,
    with each such part on a separate output line.
</code></pre>

What does `"\w*STRING\w*" *` means?  
<code>\w</code> is [\_[:alnum:]], so this matches basically any "word" that contains 'STRING' (since <code>\w</code> doesn't include space). The * after the quoted section is a glob for which files (i.e., matching all files in this directory)

# Indent multiple lines in nano
[[Ref.]](https://unix.stackexchange.com/questions/106251/how-to-indent-multiple-lines-in-nano)

<p>Once you have selected the block, you can indent it using <kbd>Alt</kbd> + <code>}</code> (not the key, but whatever key combination is necessary to produce a closing curly bracket).</p>

<p>If you're using macOS and haven't reset your meta key in the terminal, the command for this will be <kbd>Esc</kbd>+<code>}</code></p>

# How to recursively chmod all directories except files?
[[Ref.]](https://superuser.com/questions/91935/how-to-recursively-chmod-all-directories-except-files)
<p>To recursively give <strong>directories</strong> read&amp;execute privileges:</p>

<pre><code>find /path/to/base/dir -type d -exec chmod 755 {} +
</code></pre>

<p>To recursively give <strong>files</strong> read privileges:  </p>

<pre><code>find /path/to/base/dir -type f -exec chmod 644 {} +
</code></pre>

