from scipy.optimize import minimize
import numpy as np
import time


def generate_test_data(M):

    N_S = np.random.randint(low=1, high=8, size=M)

    t_S = np.random.uniform(low=30000, high=60000, size=M)

    t_out = np.random.uniform(low=200, high=1000, size=M)
    t_in = np.random.uniform(low=200, high=1000, size=M)

    return [M, N_S, t_S, t_out, t_in]


def calculate_partition_plan(num_machines, num_samplers, sample_time, network_time_out, network_time_in):
    """
    Calculate partition plan D according to parameters.
    """

    def sampling_time_cost(D, N_S, t_S, t_out, t_in):
        # Over/under-assign rates
        O = ((D - 1) / D).clip(min=0)
        U = ((1 - D) / D).clip(min=0)
        # Actual sampling time
        T_S = (D * t_S) / N_S
        # Communication time
        T_C = O * t_out + U * t_in

        return np.max(T_S + T_C)
    
    cons = {
        'type': 'eq',
        'fun': lambda D: np.sum(D) - num_machines
    }
    bnds = ((1e-10, None) for _ in range(num_machines))
    initial_guess = num_samplers / np.sum(num_samplers) * num_machines

    res = minimize(
        fun=sampling_time_cost,
        x0=initial_guess,
        method='SLSQP',
        args=(num_samplers, sample_time, network_time_out, network_time_in),
        bounds=bnds,
        constraints=cons
    )

    return res.x

# start_M = 2
# end_M = 100

# x_val = np.arange(start_M, end_M + 1)
# y_val = []
# for M in range(start_M, end_M + 1):
#     print(f'Testing M={M}')
#     num_trials = 15
#     et = np.empty(num_trials)
#     for i in range(num_trials):
#         data = generate_test_data(M)

#         start = time.time()
#         D = calculate_partition_plan(*data)
#         end = time.time()

#         et[i] = (end - start) * 1000

#     y_val.append(np.mean(et))
