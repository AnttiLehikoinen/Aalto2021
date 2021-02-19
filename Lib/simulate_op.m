
args = struct();
args.UDC = dim.Ubus;
args.N_PRE = 5;
args.periods_pre = 1/12;
args.N_DETAILED = 10;
args.periods_detailed = 1/12;

iterator = OPsimulator(motor, args);
[solution, id, iq] = iterator.get_op( dim.T_target, dim.rpm )


return

%eqcircuit = SynEquivalentCircuit.from_model( motor, 'angle', linspace(0, pi/20, 5) );
%eqcircuit.Umax = dim.Ubus/sqrt(3);
%[id, iq, Ed, Eq] = eqcircuit.get_op_MTPA(dim.rpm, dim.T_target)
%sqrt( Ed^2 + Eq^2 ) * sqrt(3)

eqcircuit.phases = 6;

%[ed, eq, Edq] = eqcircuit.voltage( dim.rpm, 0, Ipeak*2 )
%sqrt( ed^2 + eq^2 )*sqrt(3)
%eqcircuit.torque( 0,  Ipeak*2 )

[id, iq, Ed, Eq, mode] = eqcircuit.get_op(dim.rpm, dim.T_target)

sqrt(Ed^2 + Eq^2)*sqrt(3)*12/10

eqcircuit.torque(id, iq)