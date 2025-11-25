//
//  lv_core.hpp
//  PredatorPreyPlotter
//
//  Created by Devin R Cohen on 11/23/25.
//

#ifndef lv_core_hpp
#define lv_core_hpp

#include <iostream>
#include <vector>

struct LVResultVectors {
    std::vector<double> t;
    std::vector<double> prey;
    std::vector<double> predator;
};

LVResultVectors lv_solve(
     double alpha,
     double beta,
     double gamma,
     double delta,
     double x0,
     double y0,
     double dt,
     int steps
);

#endif /* lv_core_hpp */
