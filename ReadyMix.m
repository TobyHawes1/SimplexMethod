clear
%Type of problem -> either "Maximise" or "Minimise"
problem = "Maximise";

%Number of initial variables in the problem
init_vars = 2;
syms x [1,init_vars]

%Ready Mix (Maximise) (Pass) SOL -> 21
z = 5*x1 + 4*x2;
constraints = [6*x1 + 4*x2 <= 24,...
    x1 + 2*x2 <= 6,...
    -x1 + x2 <= 1,...
    x2 <= 2];

[solution,create_solution] = Code_SimplexMethod(problem,init_vars,z,constraints);

if create_solution == "True"
    %Format solutions
    disp("Solutions:")
    disp(solution.op_sol)
    disp(solution.z)
else
    disp(solution)
end