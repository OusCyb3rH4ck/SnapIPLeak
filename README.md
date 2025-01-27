# SnapIPLeak
SnapIPLeak is a script to capture and leak a victim's IP address through a Snapchat call using ARP spoofing and packet analysis.

![image](https://github.com/user-attachments/assets/8e60e698-a83f-4d59-9fd5-4816454e1124)
![image](https://github.com/user-attachments/assets/19030136-aee4-49af-9dea-d3fe88b6bf9b)

## Installation
- `git clone https://github.com/OusCyb3rH4ck/SnapIPLeak`
- `cd SnapIPLeak`
- `chmod +x SnapIPLeak.sh`

## Usage
Just run the script and follow the instructions. You only need to call the victim and wait for about 5 seconds to capture their public IP address.
- `sudo ./SnapIPLeak.sh`

## Important Notes
For those of you who are having trouble: please, **you must call the victim exactly when the script asks you to**, not before and not after, **_because the IP leaks in the first few seconds of the call_**. If you call before running the script or before it tells you to call, it won’t work.
