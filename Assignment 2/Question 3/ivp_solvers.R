#########################################################
## Derivatives as described in question 3
#########################################################

dy_dt_i <- function(t, y){
	return((-y) * log(y));
}

dy_dt_ii <- function(t, y){
	return(1 - (4*y));
}

dy_dt_iii <- function(t, y){
	return(y);
}

#########################################################
## Solutions to above derivatives, found analytically
#########################################################

# y = 0.5^e^-t
y_i_analytical <- function(t){
	return((0.5)^(exp(1)^-t))
}

# y = (1 + 3*(e^-4t)) / 4
y_ii_analytical <- function(t){
	temp <- (exp(1) ^ ((-4) * t)) * 3;
	temp <- temp + 1;
	temp <- temp / 4;
	return(temp);
}

# y = e^t
y_iii_analytical <- function(t){
	return(exp(1)^t)
}

#########################################################
## Solver functions
## Note: these return a list that contains y(t) and the maximum error
#########################################################

# Returns the last y value and the maximum error.
euler_forward <- function(dy_dt = function(t, y){}, y_func = function(t){}, initial_val, step_size, start, end){
	num_steps <- (end - start) / step_size;
	y_prev <- initial_val;
	y_next <- 0;
	max_err <- 0;
	for(i in 1:num_steps){
		t <- start + ((i - 1) * step_size);
		y_next <- y_prev + (step_size * dy_dt(t, y_prev));
		y_prev <- y_next;
		y_actual <- y_func(t);
		err <- abs(y_actual - y_next);
		if(err > max_err){
			max_err <- err;
		}
	}
	return(list(y_next, max_err));
}

trapezoid_predictor_corrector <- function(dy_dt = function(t, y){}, y_func = function(t){}, initial_val, step_size, start, end){
	num_steps <- (end - start) / step_size;
	y_prev <- initial_val;
	y_next <- 0;
	max_err <- 0;
	for(i in 1:num_steps){
		# Predict using forward euler's method
		t <- start + ((i - 1) * step_size);
		y_next <- y_prev + (step_size * dy_dt(t, y_prev));
		# Now correct with trapezoidal rule
		y_next <- y_prev + (0.5 * step_size * (dy_dt(t, y_prev) + dy_dt(t + step_size, y_next)));
		y_prev <- y_next;
		y_actual <- y_func(t);
		err <- abs(y_actual - y_next);
		if(err > max_err){
			max_err <- err;
		}
	}
	return(list(y_next, max_err));
}

runge_kutta_2nd_order <- function(dy_dt = function(t, y){}, y_func = function(t){}, initial_val, step_size, start, end){
	num_steps <- (end - start) / step_size;
	half_step_size = step_size / 2;
	y <- initial_val;
	t <- start;
	max_err <- 0;
	for(i in 1:num_steps){
		k1 <- dy_dt(t, y);
		k2 <- dy_dt(t + step_size, y + (step_size * k1));
		y <- y + (0.5 * step_size * k1) + (0.5 * step_size * k2);
		y_actual <- y_func(t);
		err <- abs(y_actual - y);
		if(err > max_err){
			max_err <- err;
		}
		t <- t + (i * step_size);
	}
	return(list(y, max_err));
}

runge_kutta_4th_order <- function(dy_dt = function(t, y){}, y_func = function(t){}, initial_val, step_size, start, end){
	num_steps <- (end - start) / step_size;
	half_step_size = step_size / 2;
	y <- initial_val;
	t <- start;
	max_err <- 0;
	for(i in 1:num_steps){
		k1 <- dy_dt(t, y);
		k2 <- dy_dt(t + half_step_size, y + (half_step_size * k1));
		k3 <- dy_dt(t + half_step_size, y + (half_step_size * k2));
		k4 <- dy_dt(t + step_size, y + (step_size * k3));
		y <- y + (step_size / 6) * (k1 + (2 * (k2 + k3)) + k4);
		y_actual <- y_func(t);
		err <- abs(y_actual - y);
		if(err > max_err){
			max_err <- err;
		}
		t <- t + (i * step_size);
	}
	return(list(y, max_err));
}

#########################################################
## Functions that use the solvers to perform the required tasks
#########################################################

num_grid_sizes <- 10;
grid_sizes_inverted <- c(2,4,8,16,32,64,128,256,512,1024);

# Takes a dy/dt function and an initial value, then uses euler's method to solve
# it with the various grid sizes defined above.
run_euler_with_grids <- function(dy_dt = function(t, y){}, y_func = function(t){}, initial_val, output_file){
	results <- c("n=h^-1", "yn(t=1)", "En");
	write(results, output_file, ncolumns=3, append=FALSE, sep="\t");
	for(i in 1:num_grid_sizes){
		result <- euler_forward(dy_dt, y_func, initial_val, 1 / grid_sizes_inverted[i], 0, 1);
		results <- c(grid_sizes_inverted[i], result[[1]], result[[2]]);
		write(results, output_file, ncolumns=3, append=TRUE, sep="\t");
	}
}

# Takes a dy/dt function and an initial value, then uses trapezoid predictor 
# corrector to solve it with the various grid sizes defined above.
run_trapezoid_with_grids <- function(dy_dt = function(t, y){}, y_func = function(t){}, initial_val, output_file){
	results <- c("n=h^-1", "yn(t=1)", "En");
	write(results, output_file, ncolumns=3, append=FALSE, sep="\t");
	for(i in 1:num_grid_sizes){
		result <- trapezoid_predictor_corrector(dy_dt, y_func, initial_val, 1 / grid_sizes_inverted[i], 0, 1);
		results <- c(grid_sizes_inverted[i], result[[1]], result[[2]]);
		write(results, output_file, ncolumns=3, append=TRUE, sep="\t");
	}
}

# Takes a dy/dt function and an initial value, then uses 2nd and 4th order 
# Runge-Kutta to solve it with the various grid sizes defined above.
run_runge_kutta_with_grids <- function(dy_dt = function(t, y){}, y_func = function(t){}, initial_val, output_file){
	results <- c("n=h^-1", "RK2yn(t=1)", "RK2 En", "RK4yn(t=1)", "RK4 En");
	write(results, output_file, ncolumns=5, append=FALSE, sep="\t");
	for(i in 1:num_grid_sizes){
		result_2 <- runge_kutta_2nd_order(dy_dt, y_func, initial_val, 1 / grid_sizes_inverted[i], 0, 1);
		result_4 <- runge_kutta_4th_order(dy_dt, y_func, initial_val, 1 / grid_sizes_inverted[i], 0, 1);
		results <- c(grid_sizes_inverted[i], result_2[[1]], result_2[[2]], result_4[[1]], result_4[[2]]);
		write(results, output_file, ncolumns=5, append=TRUE, sep="\t");
	}
}

plot_runge_kutta <- function(){
	step_size <- 1/4;
	num_its <- 4; # range is 0-1 and step size is 1/4 so 4 iterations
	intial_val_rk2 <- 0.5;
	intial_val_rk4 <- 0.5;
	rk2_results = c(length=4);
	rk4_results = c(length=4);
	for(i in 1:num_its){
		start_t <- (i-1)*step_size; # i-1 so we start from 0
		end_t <- i*step_size;
		# First do second order RK and save values
		temp <- runge_kutta_2nd_order(dy_dt_i, y_i_analytical, intial_val_rk2, step_size, start_t, end_t);
		intial_val_rk2 <- temp[[1]];
		rk2_results[i] <- temp[[1]];
		# Now forth order RK
		temp <- runge_kutta_4th_order(dy_dt_i, y_i_analytical, intial_val_rk4, step_size, start_t, end_t);
		rk4_results[i] <- temp[[1]];
		intial_val_rk4 <- temp[[1]];
	}
	x_indices <- c(0.25, 0.5, 0.75, 1);
	title <- "RK2 (black), RK4 (green) and actual (red)\nOver [0,1] with step size 0.25";
	plot(y_i_analytical, 0, 1, col="red", ylim=c(0.55, 0.79), ylab="y(t)", xlab="t", main = title);
	lines(y = rk2_results, x = x_indices, col="black");
	lines(y = rk4_results, x = x_indices, col="green");
	# Uncomment to save to an image
	#dev.copy(jpeg,"graph.jpg");
	#dev.off();
}

do_work <- function(){
	run_euler_with_grids(dy_dt_i, y_i_analytical, 0.5, "forward_i.txt");
	run_euler_with_grids(dy_dt_ii, y_ii_analytical, 1, "forward_ii.txt");
	run_euler_with_grids(dy_dt_iii, y_iii_analytical, 1, "forward_iii.txt");
	run_trapezoid_with_grids(dy_dt_i, y_i_analytical, 0.5, "implicit.txt");
	run_runge_kutta_with_grids(dy_dt_i, y_i_analytical, 0.5, "rungekutta.txt");
	plot_runge_kutta();
}
