clear
%Type of problem -> either "Maximise" or "Minimise"
problem = "Maximise";

%Number of initial variables in the problem
init_vars = 6;
syms x [1,init_vars]

% Displaying when 3rd constraint decreases independently to investigate
% when it becomes binding
Comp = zeros(1,9);
for i = 0:8
    z = 2*x1 + 3*x2 + 4*x3 + x4 + 8*x5 + x6;
    constraints = [x1 - x2 + 2*x3 + x5 + x6 == 18,...
        x2 - x3 + x4 + 3*x6 <= 8,...
        x1 + x2 - 3*x3 + x4 + x5 <= 36-i,...
        x1 - x2 + x5 + x6 <= 23];
    [solution,create_solution] = Code_SimplexMethod(problem,init_vars,z,constraints);
    if create_solution == "True"
        disp("Constraints")
        disp(constraints)
        disp("Solutions:")
        disp(solution.op_sol)
        disp(solution.z)
    else
        disp(solution)
    end
      Comp(1,i+1) = solution.z{2,1};
end
figure
plot(36:-1:28,Comp,'-')
xlabel('Resource 3')
ylabel('Optimal Solution')
ax = gca;
ax.XDir = 'reverse';
ylim([230,233])
