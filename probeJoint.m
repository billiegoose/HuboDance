function probeJoint(robotid, joint)
temp = orBodyGetJointValues(robotid, joint);
for angle=[0:0.1:pi pi:-0.1:0]
    orBodySetJointValues(robotid,temp+angle,joint);
    pause(0.01);
end
orBodySetJointValues(robotid,temp,joint);