
In case anyone other than myself stumbles across this:
I don't know why you're interested in this, but okay!
Right now it's got all my crap in it, since I made this specifically for myself, so I could just download this repo, run a command, and presto my workspace is up and running!
If you _really_ want to use this for some reason, there's two parts:

List out all the repositories you want to have tracked in your workspace in the `repo-list` folder. These should be typed as you would normally for `git clone ...`.
The only restriction, is they must end with `.git`. Even if git is smart enough to know it should be there, my scripts are dumb and need it there.

If you want to do any additional configuration after cloning, or create projects/builds, you can do so in the `config` folder. There is a `global` file is used to configure every repository you clone, but you can also make repository pecific configurations by just making a file with the name of the repository you want to configure.
These files are just `source`d in the scripts, so you can write any valid command you like in here, and it'll chug along just fine.

I don't know. I think that's it?
I need to write a better version of this one day.
