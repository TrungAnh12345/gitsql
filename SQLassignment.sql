/********* A. BASIC QUERY *********/

-- 1. Liệt kê danh sách sinh viên sắp xếp theo thứ tự:
--      a. id tăng dần
--      b. giới tính
--      c. ngày sinh TĂNG DẦN và học bổng GIẢM DẦN
select * from student order by student.id;
select * from student order by student.gender;
select * from student order by student.bithday ASC, student.scholarship DESC; 



-- 2. Môn học có tên bắt đầu bằng chữ 'T'
select * from subject where subject.name like 'T%';


-- 3. Sinh viên có chữ cái cuối cùng trong tên là 'i'
select * from student where student.name like '%i';


-- 4. Những khoa có ký tự thứ hai của tên khoa có chứa chữ 'n'
select * from faculty where faculty.name like '_n%';


-- 5. Sinh viên trong tên có từ 'Thị'
select * from student where student.name like '%Thị%';

-- 6. Sinh viên có ký tự đầu tiên của tên nằm trong khoảng từ 'a' đến 'm', sắp xếp theo họ tên sinh viên
select * from student where student.name between 'A' and 'M' order by student.name;


-- 7. Sinh viên có học bổng lớn hơn 100000, sắp xếp theo mã khoa giảm dần
select * from student where student.scholarship > 100000 order by faculty_id DESC;


-- 8. Sinh viên có học bổng từ 150,000 trở lên và sinh ở Hà Nội.
select * from student where student.scholarship > 150000 and hometown = 'Hà Nội';


-- 9. Những sinh viên có ngày sinh từ ngày 01/01/1991 đến ngày 05/06/1992
select * from student where student.bithday between to_date('19910101', 'YYYYMMDD') and to_date('19920605', 'YYYYMMDD');
    -- hoặc
select * from student where student.bithday between to_date('01/01/1991', 'DD/MM/YYYY') and to_date('19920605', 'YYYYMMDD');


-- 10. Những sinh viên có học bổng từ 80000 đến 150000
select * from student where student.scholarship between 80000 and 150000;


-- 11. Những môn học có số tiết lớn hơn 30 và nhỏ hơn 45
select * from subject where subject.lesson_quantity > 30 and subject.lesson_quantity < 45;


-------------------------------------------------------------------

/********* B. CALCULATION QUERY *********/

-- 1. Cho biết thông tin về mức học bổng của các sinh viên, gồm: Mã sinh viên, Giới tính, 
        -- Mã khoa, Mức học bổng. Trong đó, mức học bổng sẽ hiển thị là “Học bổng cao” 
        -- nếu giá trị của field học bổng lớn hơn 500,000 và ngược lại hiển thị là “Mức trung bình”.
select id, name, gender, bithday, hometown, 
    case 
        when scholarship > 500000 then 'Học bổng cao' 
    else 
        case 
            when nvl(scholarship, 0) = 0 then null 
            else  'Học bổng trung bình' 
        end 
    end scholarship
from student;
		
-- 2. Tính tổng số sinh viên của toàn trường
select count(student.id) as total_student from student;


-- 3. Tính tổng số sinh viên nam và tổng số sinh viên nữ.
select gender, count(*) count from student group by gender;
-- select s.gender , count(s.id) from student s group by s.gender
-- cách 2: select sum(case when gender = "Nam" then 1 else 0 end ) sl_nam
              --  sum(case when gender = "Nu" then 1 else 0 end ) sl_nu
              -- count(case when gender = "Nu" then 1 ) 
            
-- 4. Tính tổng số sinh viên từng khoa (chưa cần JOIN)
select faculty_id, count(student.id) count from student group by faculty_id;
    -- hoặc
select faculty.name faculty, count(*) count
from student, faculty
where student.faculty_id = faculty.id
group by faculty.name;


-- 5. Tính tổng số sinh viên của từng môn học
select subject_id, count(distinct student_id) total_of_student from exam_management group by subject_id;
    -- hoặc
select subject.name, count(distinct student_id) count
from subject, exam_management
where subject.id = exam_management.subject_id
group by subject.name;


-- 6. Tính số lượng môn học mà sinh viên đã học
select student_id, count(distinct subject_id) from exam_management group by student_id;


-- 7. Số lượng học bổng của mỗi khoa
select faculty_id, count(scholarship) from student group by faculty_id;
-- select falcuty_id, max(scholarship) from student group by faculty_id;

-- 8. Cho biết học bổng cao nhất của mỗi khoa
select faculty_id, max(nvl(scholarship, 0)) max_scholarship from student group by faculty_id;


-- 9. Cho biết tổng số sinh viên nam và tổng số sinh viên nữ của mỗi khoa
select faculty_id, gender, count(1) total from student where gender = 'Nam' group by faculty_id, gender
union
select faculty_id, gender, count(1) total from student where gender = 'Nữ' group by faculty_id, gender;
    -- hoặc
select faculty.name, 
    count(case when gender = 'Nam' then 1 else 0 end) total_male,
    count(case when gender = 'Nữ' then 1 else 0 end) total_female
from student, faculty
where student.faculty_id = faculty.id
group by faculty.name;

-- 10. Cho biết số lượng sinh viên theo từng độ tuổi (show ra tuổi)
select to_number(to_char(sysdate, 'YYYY')) - to_number(to_char( 'YYYY')) age, count(student.id) student_number 
from student 
group by to_number(to_char(sysdate, 'YYYY')) - to_number(to_char(bithday, 'YYYY'));

-- hoặc select age, count(id) from( select id, to_char(sysdate, 'yyyy') -  to_char (birthday, 'yyyy') age from student) group by age
-- hoặc extract year from current_date -- không nên dùng extract vì chậm

-- 11. Cho biết những nơi nào có hơn 2 sinh viên đang theo học tại trường
select hometown, count(student.id) student_count 
from student 
group by hometown 
having count(student.id) > 2;

-- 12. Cho biết những sinh viên thi lại từ 2 lần trở lên
select student_id, subject_id, count(number_of_exam_taking) number_of_exam_taking
from exam_management
group by student_id, subject_id
having count(number_of_exam_taking) >= 2;
-- hoặc select student_id, subject_id, count(*) from exam_management group by student_id, subject_id having count(*) >= 2
-- 13. Cho biết những sinh viên nam có điểm trung bình lần 1 trên 7.0 
select s.name, avg(mark) avg_mark
from student s
join exam_management e on s.id = e.student_id
where s.gender = 'Nam' and e.number_of_exam_taking = 1
group by s.name
having avg(mark) > 7;

-- hoặc select s.name, avg(mark) avg_mark
-- from student s, exam_management ẽ
--where s.id = ex.student_id
--and s.gender = 'Nam'
--ex.number_of_taking_exam_taking = 1
-- group by s.name
--having avg(mark) > 7;


-- 14. Cho biết danh sách các sinh viên rớt từ 2 môn trở lên ở lần thi 1 (rớt môn là điểm thi của môn không quá 4 điểm)
select s.name, count(e.subject_id) failed_subject
from student s
join exam_management e on s.id = e.student_id
where e.number_of_exam_taking = 1 and e.mark < 4
group by s.name
having count(e.subject_id) >= 2;
-- hoặc select student_id count(*) from exam_management where number_of_exam_taking = 1 and mark < 4.0 group by student_id having count(*) >= 2

-- 15. Cho biết danh sách những khoa có nhiều hơn 2 sinh viên nữ (chưa cần JOIN)
select faculty.name, count(gender) student_count
from student, faculty
where student.faculty_id = faculty.id
    and gender = 'Nữ'
group by faculty.name
having count(gender) > 2;


-- 16. Cho biết những khoa có 2 sinh viên đạt học bổng từ 200000 đến 300000
select faculty_id, count(student.id) student_number
from student
where scholarship between 200000 and 300000
group by faculty_id
having count(id) = 2;


-- 17. Cho biết sinh viên nào có học bổng cao nhất
select * 
from student
where scholarship = (select max(scholarship) from student);

-------------------------------------------------------------------

/********* C. DATE/TIME QUERY *********/

-- 1. Sinh viên có nơi sinh ở Hà Nội và sinh vào tháng 02
select student.name, hometown, bithday 
from student
where to_char(bithday, 'MM') = '02' 
    and hometown = 'Hà Nội';


-- 2. Sinh viên có tuổi lớn hơn 30 (show ra tuổi của từng sinh viên)
select s.name, to_number(to_char(sysdate, 'YYYY')) - to_number(to_char(s.bithday, 'YYYY')) age
from student s
where to_number(to_char(sysdate, 'YYYY')) - to_number(to_char(s.bithday, 'YYYY')) > 30;


-- 3. Sinh viên sinh vào mùa xuân năm 1990
select student.name, hometown, bithday 
from student
where to_char(bithday, 'MM') in ('01', '02', '03') 
    and to_char(bithday, 'YYYY') = '1991';


-------------------------------------------------------------------


/********* D. JOIN QUERY *********/

-- 1. Danh sách các sinh viên của khoa ANH VĂN và khoa VẬT LÝ
select student.name, faculty.name 
from student, faculty
where student.faculty_id = faculty.id 
and (faculty.name = 'Anh - Văn' or faculty.name = 'Vật lý');
    -- hoặc 
select s.name student_name, f.name faculty_name
from student s
join faculty f on s.faculty_id = f.id
where f.name = 'Anh - Văn' 
    or f.name = 'Vật lý';



-- 2. Những sinh viên nam của khoa ANH VĂN và khoa TIN HỌC
select s.name student_name, f.name faculty_name
from student s
join faculty f on s.faculty_id = f.id
where (f.name = 'Anh - Văn' or f.name = 'Tin học') 
    and s.gender = 'Nam';


-- 3. Cho biết sinh viên nào có điểm thi lần 1 môn cơ sở dữ liệu cao nhất
select student.name, exam_management.mark 
from exam_management
join student on student.id = exam_management.student_id
join subject s on s.id = exam_management.subject_id
where number_of_exam_taking = 1 
    and s.name = 'Cơ sở dữ liệu'
and mark = (
    select max(mark) 
    from exam_management
    join subject s on s.id = exam_management.subject_id
    where number_of_exam_taking = 1 and s.name = 'Cơ sở dữ liệu'
);


-- 4. Cho biết sinh viên khoa anh văn có tuổi lớn nhất.
with lit_eng_students as (
    select student.*, faculty.name faculty_name
    from student
    join faculty on faculty.id = student.faculty_id
    where faculty.name = 'Anh - Văn'
)
select * 
from lit_eng_students
where bithday = (select min(bithday) min_birthday from lit_eng_students);

-- 

-- 5. Cho biết khoa nào có đông sinh viên nhất
select faculty.name, count(student.id) student_number
from faculty, student    
where faculty.id = student.faculty_id 
group by faculty.name 
having count(student.faculty_id) >= all(select count(student.id) from student group by student.faculty_id);
-- h


-- 6. Cho biết khoa nào có đông nữ nhất
select faculty.name, count(gender) student_number
from faculty,student
where faculty.id = student.faculty_id 
    and gender = 'Nữ'
group by faculty.name 
having count(student.faculty_id) >= all(select count(gender) from student where gender ='Nữ' group by student.faculty_id);


-- 7. Cho biết những sinh viên đạt điểm cao nhất trong từng môn
with max_mark as (
    select subject_id, max(mark) max_mark
    from exam_management
    group by subject_id
)
select s.name student, sb.name subject, mm.max_mark
from student s
join exam_management em on em.student_id = s.id
join max_mark mm on mm.subject_id = em.subject_id and mm.max_mark = em.mark
join subject sb on sb.id = mm.subject_id;


-- 8. Cho biết những khoa không có sinh viên học
select faculty.name, count(student.id) student_number
from faculty
left join student on faculty.id = student.faculty_id
group by faculty.name
having count(student.id) = 0;


-- 9. Cho biết sinh viên chưa thi môn cơ sở dữ liệu
select s.id, s.name
from student s
left join exam_management em on s.id = em.student_id
left join subject sb on em.subject_id = sb.id
group by s.id, s.name
having sum(case when sb.name = 'Cơ sở dữ liệu' then 1 else 0 end) = 0;
    -- hoặc với 1 cách dài dòng hơn
with temp_student as(
    select distinct s.id, s.name
    from student s
    join exam_management em on s.id = em.student_id
    left join subject sb on em.subject_id = sb.id
    where sb.name = 'Cơ sở dữ liệu'
)
select * 
from student s
where s.id not in (select * from temp_student);
-- hoặc 
-- with temp_student as()
--select * 
--from student 
--where id not in (select * from temp_student)
-- 10. Cho biết sinh viên nào không thi lần 1 mà có dự thi lần 2
select student.name, number_of_exam_taking 
from exam_management
join student on student.id = exam_management.student_id
where number_of_exam_taking = 2 
    and not exists (
        select id , student_id, subject_id, exam_management.number_of_exam_taking , mark
        from exam_management 
        where number_of_exam_taking = 1 and student.id = exam_management.student_id
        
        
        
-- 7. Cho biết những sinh viên đạt điểm cao nhất trong từng môn
select subject_id , max (e.mark)
from exam_management e
group by subject_id),
select e.student_id, e.subject_id, e.mark
from exam_management e join max_mark_by_student on max_mark_by_student
-- 1. Danh sách các sinh viên của khoa ANH VĂN và khoa VẬT LÝ

-- 2. Những sinh viên nam của khoa ANH VĂN và khoa TIN HỌC

-- 3. Cho biết sinh viên nào có điểm thi lần 1 môn cơ sở dữ liệu cao nhất

-- 4. Cho biết sinh viên khoa anh văn có tuổi lớn nhất.

-- 5. Cho biết khoa nào có đông sinh viên nhất

-- 6. Cho biết khoa nào có đông nữ nhất


-- 8. Cho biết những khoa không có sinh viên học

-- 9. Cho biết sinh viên chưa thi môn cơ sở dữ liệu

-- 10. Cho biết sinh viên nào không thi lần 1 mà có dự thi lần 2

