clear
%Type of problem -> either "Maximise" or "Minimise"
problem = "Maximise";

%Number of initial variables in the problem
init_vars = 6;
syms x [1,init_vars]

% Our Problem (Maximise) (Pass) -> SOL: 232
z = 2*x1 + 3*x2 + 4*x3 + x4 + 8*x5 + x6;
constraints = [x1 - x2 + 2*x3 + x5 + x6 == 18,...
    x2 - x3 + x4 + 3*x6 <= 8,...
    x1 + x2 - 3*x3 + x4 + x5 <= 36,...
    x1 - x2 + x5 + x6 <= 23];

[solution,create_solution] = Code_SimplexMethod(problem,init_vars,z,constraints);

if create_solution == "True"
    %Format solutions
    disp("Solutions:")
    disp(solution.op_sol)
    disp(solution.z)
else
    disp(solution)
end