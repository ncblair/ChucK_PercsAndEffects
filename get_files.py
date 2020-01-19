import os
import shutil

direc = os.getcwd() + "/audio/Percussion"
direc2 = os.getcwd() + "/audio/HatPerc"

# files = os.listdir(direc)
# files = [f for f in files if f.endswith(".wav")]
# [shutil.move(f"{direc}/{f}", f"{direc2}") for f in files]


files = [f for f in os.listdir(direc2) if f.endswith(".wav")]
string = "["
for f in files:
	string += f"\"{f}\", "
string = string[:-2]
string += "]"
print(string)