create database QLCafe
use QLCafe
drop database QLCafe


create table TaiKhoan(
TenDN varchar(100) primary key not null,
MatKhau varchar(100),
MaDK varchar(50)
)
drop table TaiKhoan
insert into TaiKhoan
values ('Admin', 'admin321','quantriquancf'),
		('Staff','staff456','')
select * from TaiKhoan

create table NhanVien(
MaNV int identity primary key not null, 
TenNV nvarchar(50), 
GioiTinh nvarchar(10),
Chucvu nvarchar(50), 
NgaySinh date, 
Diachi nvarchar(50), 
NgayVaoLam date
)


drop table DoUong
create table DoUong(
TenDo nvarchar(50) primary key not null,
Dongia float
);
insert into DoUong
values (N'Nước Chanh Tươi','25000'),
       (N'Nước Cam','25000'),
		(N'Bạc Xỉu','25000'),
		(N'Nước Dừa','25000'),
		(N'Cà Phê Nâu Phin','20000'),
		(N'Cà Phê Đen Phin','20000');
select * from DoUong		
		


drop table Ban

create table Ban(
SoBan nvarchar(20) primary key not null,
tinhtrang nvarchar(50) default N'Trống'
);
declare @i int =1
while(@i<=13)
begin
	insert into Ban
	values ('Bàn '+cast(@i as nvarchar(50)),N'Trống');
	set @i = @i +1;	
end

drop table HoaDon

create table HoaDon(
MaHD int identity primary key not null ,
SoBan nvarchar(20),
Tongtien float,
ThoiGianNhap datetime,
TinhTrang nvarchar(50)
)

alter table HoaDon
alter column ThoiGianNhap char(20)

drop table ThongTinHD

create table ThongTinHD(
MaHD int ,
MaDS int,
SoBan nvarchar(20),
tendo nvarchar(50) ,
soluong int,
thanhtien float,
foreign key(MaHD) references HoaDon(MaHD),
foreign key(MaDS) references DSDoGoi(MaDS),
foreign key(SoBan) references Ban(SoBan),
)


drop table ThongTinDSDoGoi

create table ThongTinDSDoGoi(
MaDS int,
SoBan nvarchar(20),
tendo nvarchar(50),
Dongia float,
Note nvarchar(500),
foreign key(MaDS) references DSDoGoi(MaDS)
)
alter table ThongTinDSDoGoi
add MaDS int,foreign key(MaDS) references DSDoGoi(MaDS)

update ThongTinDSDoGoi
set MaDS = (select top 1 MaDS from DSDoGoi 
			where DSDoGoi.SoBan = ThongTinDSDoGoi.SoBan
			order by MaDS desc )

create table DSDoGoi(
MaDS int identity primary key not null,
SoBan nvarchar(20),
foreign key(SoBan) references Ban(SoBan)
)

drop table DSDoGoi
delete from DSDoGoi
where SoBan = 'Bàn 4';
insert into DSDoGoi values (N'Bàn 4');
insert into ThongTinDSDoGoi(SoBan,tendo,Note)
values (N'Bàn 5', N'Nước Cam',N'Thêm ĐƯờng' ),(N'Bàn 9', N'Nước Cam',N'Thêm ĐƯờng' )

 
select * from DoUong
select * from Ban
select * from ThongTinHD
select * from DSDoGoi
select * from ThongTinDSDoGoi
select * from HoaDon
insert into ThongTinHD(MaHD)



go
--ThongTinHD


update HoaDon
set Tongtien = (select sum(thanhtien) from ThongTinHD, ThongTinDSDoGoi
where ThongTinHD.MaDS = ThongTinDSDoGoi.MaDS)
go

create trigger them_ThongTinHD
on ThongTinHD for insert
as
	update ThongTinHD
	set soluong = (select  count(ThongTinDSDoGoi.tendo) from ThongTinDSDoGoi
	where ThongTinDSDoGoi.MaDS = ThongTinHD.MaDS and ThongTinHD.tendo = ThongTinDSDoGoi.tendo and ThongTinDSDoGoi.SoBan = ThongTinHD.SoBan)
	update ThongTinHD
	set thanhtien = soluong*Dongia from ThongTinHD, ThongTinDSDoGoi
	where ThongTinHD.MaDS = ThongTinDSDoGoi.MaDS and ThongTinHD.tendo = ThongTinDSDoGoi.tendo
	update ThongTinHD
	set MaHD = (select top 1 MaHD from HoaDon order by MaHD desc)

create proc Insert_ThongTinHD 
as begin
	insert into ThongTinHD(tendo,MaDS ,SoBan)
	select distinct tendo, MaDS , ThongTinDSDoGoi.SoBan from ThongTinDSDoGoi
	where  MaDS not in (select MaDS from ThongTinHD) 
	order by ThongTinDSDoGoi.SoBan;
end
exec Insert_ThongTinHD ;
go

--ThongTinDSDoGoi'
alter trigger Them_Do
on ThongTinDSDoGoi for insert
as 
	update ThongTinDSDoGoi
	set Dongia = (select Dongia from DoUong where TenDo = ThongTinDSDoGoi.tendo)
	update ThongTinDSDoGoi
	set MaDS = (select top 1 MaDS from DSDoGoi 
			where DSDoGoi.SoBan = ThongTinDSDoGoi.SoBan
			order by MaDS desc )

go
 
 drop trigger TinhTrang2_Ban
create trigger TinhTrang2_Ban
on ThongTinDSDoGoi for insert
as
	if(exists (select SoBan from ThongTinDSDoGoi))
	begin 
	update Ban 
	 set tinhtrang = N'Có Khách' 
	 where SoBan = (select SoBan from ThongTinDSDoGoi)
	end
	else
	begin
	update Ban 
	 set tinhtrang = N'Trống' 
	 where SoBan = (select SoBan from ThongTinDSDoGoi)
	end
go

--Bàn
 TinhTrang_Ban
as
begin
	declare @y nvarchar(10)
	select @y = MaDS from ThongTinDSDoGoi
	if(exists (select*from ThongTinHD where MaDS = @y ))
	begin	
	update HoaDon
	set TinhTrang = N'Có khách'
	end
	else
	begin
	update Ban 
	 set tinhtrang = N'Trống' 
	 where SoBan = (select distinct SoBan from ThongTinDSDoGoi)
	end
end

exec TinhTrang_Ban

go
--DSDoGoi
drop trigger Them_DSDoGoi
create trigger Them_DSDoGoi
on DSDoGoi for insert
as
	insert into ThongTinDSDoGoi(SoBan)
	select SoBan from DSDoGoi 
	where DSDoGoi.MaDS = ThongTinDSDoGoi.MaDS

go
alter proc tongtien
as
begin
	update HoaDon
	set Tongtien = (select sum(thanhtien) from ThongTinHD
	where ThongTinHD.MaHD = HoaDon.MaHD)
	end
	exec tongtien
delete from ThongTinHD
where MaHD = 6
--HoaDon
select * from HoaDon
select * from ThongTinDSDoGoi
alter trigger them_HoaDon
on HoaDon for insert
as
	update HoaDon
	set Tongtien = (select sum(thanhtien) from ThongTinHD,inserted
	where ThongTinHD.MaHD = inserted.MaHD)
	update HoaDon
	set ThoiGianNhap = cast(getdate() as char(16)) 
	where MaHD = (select MaHD from inserted)	
	update HoaDon
	set TinhTrang = N'Chưa thanh toán'
	where MaHD = (select MaHD from inserted)

go

-- xác nhận thanh toán
create trigger XacNhan
on ThongTinDSDoGoi for delete
as
update HoaDon
	set TinhTrang = N'Đã thanh toán'
	where MaHD = (Select MaHD from deleted,ThongTinHD
					where deleted.MaDS = ThongTinHD.MaDS)

go


--Thanh toán
alter function f_ShowBils(@a nvarchar(10))
returns @ShowBils table(MaHD varchar(10),
						MaDS varchar(10),
						SoBan nvarchar(20),
						TenDo nvarchar(50),
						Dongia int,
						SoLuong int,
						ThanhTien int,
						TongTien int)
as begin
insert into @ShowBils
select HoaDon.MaHD,ThongTinHD.MaDS,ThongTinHD.SoBan,ThongTinHD.tendo,Dongia, soluong, thanhtien, TongTien
from ThongTinHD, DoUong, HoaDon
where DoUong.TenDo = ThongTinHD.tendo and ThongTinHD.SoBan = @a and ThongTinHD.MaHD = HoaDon.MaHD  
return 
end
go
select * from f_ShowBils('Bàn 13')

drop function f_ShowBils
--xem chi tiết
create function f_ShowBillsDetails(@b nvarchar(10))
returns @ShowBillsDetails table(MaHD varchar(10),
						MaDS varchar(10),
						SoBan nvarchar(20),
						TenDo nvarchar(50),
						Dongia int,
						SoLuong int,
						ThanhTien int)
as begin
insert into @ShowBillsDetails
select ThongTinHD.MaHD,ThongTinHD.MaDS,HoaDon.SoBan, ThongTinHD.tendo,Dongia, soluong, thanhtien
from ThongTinHD, HoaDon, DoUong
where  ThongTinHD.MaHD = @b and DoUong.TenDo = ThongTinHD.tendo
return 
end

--Thay đổi bảng DoUong
select * from DoUong
create proc ThayDoi_Menu @H nvarchar(50), @u int, @y nvarchar(50)
as begin
update DoUong
set Dongia = @u
where TenDo =@y
update DoUong
set TenDo = @H
where TenDo =@y
end

exec ThayDoi_Menu (N'Nước Gạo', '20000', 


	






--