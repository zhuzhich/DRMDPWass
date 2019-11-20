p = [0.3 0.3 0.2,0.2;
	0.4 0.3 0.2,0.1;
	0.1 0.7 0.1,0.1];	%action * state

pi = [0.5;0.3;0.2];	%action * 1

v = [1;2;3;4]; %state * 1

res = 0;
for a=1:3
	res1 = 0;
	for s=1:4
		res1 = res1 + p(a,s)*v(s);
	end
	res = res + pi(a)*res1;
end

res_summation = res

res_matrix = (p*v)'*pi

p_vector = reshape(p',[],1);

v_vector = [];


for a=1:3
    e_v = zeros(3,1);
    e_v(a) = 1;
    temp = e_v*v';
    v_vector = [v_vector,temp];
end

v_vector

res_vector = (v_vector*p_vector)'*pi


% q = p; %action*state
% 
% p_1 = [0.3 0.3 0.2,0.2;
% 	0.4 0.3 0.2,0.1;
% 	0.1 0.7 0.1,0.1;
% 	0.3 0.3 0.3 0.1];	%state * state
% res = zeros(3,4);
% for a=1:3
% 	for s = 1:4
% 		for s_1 = 1:4
% 			res(a,s) = res(a,s) + q(a,s_1)*p_1(s_1,s);
% 		end
% 	end
% end
% res_summation = res
% 
% res_matrix = q*p_1
