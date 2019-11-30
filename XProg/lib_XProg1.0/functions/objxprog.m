function XProg = objxprog( obj )
if isa(obj,'unlinfun')
    XProg=obj.XProg;
else
    XProg=obj.Model.XProg;
end

end

