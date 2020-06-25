import os
import pygit2

class Fontship():
    def open_repo(self):
        cwd = os.getcwd()
        repo_path = pygit2.discover_repository(cwd)
        if repo_path:
            return pygit2.Repository(repo_path)
        else:
            return None
