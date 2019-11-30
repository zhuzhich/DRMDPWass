function matchxprog(obj1,obj2)
if isempty(obj1)&&isempty(obj2)
    obj1=obj2;
end
if isempty(obj2)
    obj2=obj1;
end
if isa(obj1,'unlinfun')||isa(obj1,'rule')
    XProg1=obj1.XProg;
else
    XProg1=obj1.Model.XProg;
end
if isa(obj2,'unlinfun')||isa(obj2,'rule')
    XProg2=obj2.XProg;
else
    XProg2=obj2.Model.XProg;
end

if XProg1~=XProg2
    error('Models mismatch.');
end
end

