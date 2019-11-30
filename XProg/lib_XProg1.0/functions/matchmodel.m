function matchmodel(model1,model2)
    if model1~=model2&&model1.XProg.Uncertain~=model2&&model2.XProg.Uncertain~=model1
        error('Models mismatch.');
    end
end

