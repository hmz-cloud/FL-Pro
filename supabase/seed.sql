-- FleetOps Pro — Demo Seed Data
-- Run AFTER schema.sql

insert into organizations (id, name, slug, plan, vehicle_limit)
values ('a0000000-0000-0000-0000-000000000001','Acme Fleet Co.','acme-fleet','business', null);

insert into cost_centers (org_id, name, code, budget, is_active) values
  ('a0000000-0000-0000-0000-000000000001','Operations North','OPS-N',50000,true),
  ('a0000000-0000-0000-0000-000000000001','Logistics South','LOG-S',40000,true),
  ('a0000000-0000-0000-0000-000000000001','Executive Fleet','EXC-F',80000,true),
  ('a0000000-0000-0000-0000-000000000001','Field Services','FLD-S',30000,false);

insert into vehicles (org_id,make,model,year,license_plate,fleet_number,status,vehicle_type,fuel_type,mileage,next_maintenance,insurance_expiry) values
  ('a0000000-0000-0000-0000-000000000001','Toyota','Land Cruiser',2022,'ABC-1234','FL-001','available','suv','gasoline',12400,'2026-06-10','2026-12-01'),
  ('a0000000-0000-0000-0000-000000000001','Ford','Transit',2023,'DEF-5678','FL-002','in_use','van','diesel',8700,'2026-05-25','2026-10-01'),
  ('a0000000-0000-0000-0000-000000000001','Mitsubishi','L200',2021,'GHI-9012','FL-003','maintenance','truck','diesel',31200,'2026-05-20','2026-11-01'),
  ('a0000000-0000-0000-0000-000000000001','Nissan','Patrol',2023,'JKL-3456','FL-004','available','suv','gasoline',4100,'2026-08-01','2027-01-15');
