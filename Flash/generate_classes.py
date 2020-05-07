import os
import sys
from pathlib import Path
from typing import List, Dict
from PIL import Image

script_dir = Path(os.path.dirname(os.path.abspath(__file__)))
os.chdir(script_dir)

icon_folder = Path("G:/Modding/DOS2DE/Projects_Source/WeaponExpansion/UI/MasteryBonusSkillIcons")
output_folder = script_dir.joinpath("MasteryMenu/icons")

script_template = """
package icons
{{
	import flash.display.BitmapData;
	
	public dynamic class {name} extends BitmapData
	{{
		public function {name}(w:int={width}, h:int={height})
		{{
			super(w,h);
		}}
	}}
}}
"""

def export_file(path, contents):
    try:
        path.parent.mkdir(parents=True, exist_ok=True)
        f = open(str(path.absolute()), 'w')
        f.write(contents)
        f.close()
        return True
    except Exception as e:
        print("Erroring writing '{}': {}".format(path.name, e))
    return False

files:List[str] = list(icon_folder.rglob("*.png"))
for f in files:
	name = Path(f).stem
	image = Image.open(f)
	width,height = image.size
	script = script_template.format(name=name, width=width, height=height).strip()
	export_path = output_folder.joinpath(name).with_suffix(".as")
	export_file(export_path, script)