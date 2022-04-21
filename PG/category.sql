  drop table if exists category cascade;
  create table category (id serial, category integer, name varchar);
 		
 		insert into category (category, name) 
 		values (null, 'PRINCIPAL 1'),
 		       (1, 'Sub A'),
 		       (1, 'Sub B'),
 		       (1, 'Sub C'),
 		       (2, 'Sub A.1'),
 		       (2, 'Sub A.2'),
           (null, 'PRINCIPAL 2'),
 		       (7, 'Sub A'),
 		       (7, 'Sub B'),
 		       (7, 'Sub C'),
 		       (8, 'Sub A.1'),
 		       (8, 'Sub A.2');
 		      
 		select * from category;
 	
 		with recursive cte as 
 			(select category as master, id, name, array[id] as arr from category where category is null
 				union all 
 			 select c2.category, c2.id, cte.name||' >> '||c2.name, array_append(cte.arr, c2.id) from category c2
 			 inner join cte on c2.category = cte.id
 			)
 		select * from cte;
 		      
/*
          master   |id|name                          |arr     |
          ---------|--|------------------------------|--------|
                   | 1|PRINCIPAL                     |{1}     |
                   | 7|PRINCIPAL2                    |{7}     |
                  1| 2|PRINCIPAL >> Sub A            |{1,2}   |
                  1| 3|PRINCIPAL >> Sub B            |{1,3}   |
                  1| 4|PRINCIPAL >> Sub C            |{1,4}   |
          ...      |  |                              |        | 
                  2| 5|PRINCIPAL >> Sub A >> Sub A.1 |{1,2,5} |
                  2| 6|PRINCIPAL >> Sub A >> Sub A.2 |{1,2,6} |
*/
 		
