import os
import pygit2

class Repo():

    path = None
    git = None

    def __init__(self):
        cwd = os.getcwd()
        git_path = pygit2.discover_repository(cwd)
        if git_path:
            self.path = git_path.replace("/.git/", "")
            self.git = pygit2.Repository(git_path)
        else:
            raise Exception("No Git repository detected!")
