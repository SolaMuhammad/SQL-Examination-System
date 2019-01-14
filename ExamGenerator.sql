CREATE TABLE MCQ (
   mcqQId int not null,
   studentAnswer nvarchar(200),
   primary key(mcqQId),
   CONSTRAINT Fk_mcqQId FOREIGN KEY (mcqQId)
    REFERENCES mcqQusetion(questionId) 
);
CREATE TABLE TF (
   tfQId int not null,
   studentAnswer nvarchar(200)
   primary key(tfQId),
   CONSTRAINT Fk_tfQId FOREIGN KEY (tfQId)
    REFERENCES [T&FQuestion](questionId)
);
CREATE TABLE ESSAY (
	essayId int not null,
    studentAnswer nvarchar(200)
	primary key(essayId),
    CONSTRAINT Fk_essayId FOREIGN KEY (essayId)
    REFERENCES EssayQuestion(questionId)
);


/*********** (Procedures) ***********/
create procedure getRandomMcq
as
begin
insert into MCQ(mcqQId)
select top (5)  mcqQusetion.questionId from mcqQusetion
order by NEWID()
end
create procedure getRandomTf
as
begin
insert into TF(tfQId)
select top (5)  [T&FQuestion].questionId from [dbo].[T&FQuestion]
order by NEWID()
end

create procedure getRandomEssay
as
begin
insert into ESSAY(essayId)
select top (5)  [EssayQuestion].questionId from [dbo].[EssayQuestion]
order by NEWID()
end
/*********** (Views) ***********/
----------------------- MCQ Part ---------------------
CREATE VIEW V_MCQ
AS 
SELECT questionHeader, ans1, ans2, ans3, ans4, MCQ.studentAnswer from mcqQusetion inner join MCQ
on mcqQusetion.questionId = MCQ.mcqQId
----------------------- T&F Part ---------------------
CREATE VIEW V_TF
AS 
SELECT questionHeader, ans1, ans2, TF.studentAnswer from [T&FQuestion] inner join TF
on [T&FQuestion].questionId = TF.tfQId
----------------------- Essay Part ---------------------
CREATE VIEW V_ESSAY
AS 
SELECT questionHeader,  ESSAY.studentAnswer from EssayQuestion inner join ESSAY
on EssayQuestion.questionId = ESSAY.essayId

EXECUTE getRandomMcq
EXECUTE getRandomTf
EXECUTE getRandomEssay
create procedure generateExam
as
begin

select * from V_MCQ
select * from V_TF
select * from V_ESSAY

end
generateExam
------------------------------------------------------------------
create PROCEDURE AnswerMcqQuestion 
@Answer nvarchar(50), @QId int
AS 
BEGIN 
  update MCQ set studentAnswer=@Answer where mcqQId=@QId
END

create PROCEDURE AnswerTFQuestion 
@Answer nvarchar(1), @QId int
AS 
BEGIN 
  update TF set studentAnswer=@Answer where tfQId=@QId
END

create PROCEDURE AnswerEssayQuestion 
@Answer nvarchar(200), @QId int
AS 
BEGIN 
  update [dbo].[ESSAY] set [studentAnswer]=@Answer where [essayId]=@QId
END


exec AnswerMcqQuestion 'am play',1
exec AnswerMcqQuestion 'tried',2
--------------------------------CorrectMcqQuestion----------------------------------------------------
alter PROCEDURE CorrectMcqQuestion
As
begin
declare @grade int 
set @grade=0
declare @sol nvarchar(200)
Declare @Id int
Declare @correctAnswer nvarchar(200)

While (Select Count(*) From [dbo].[MCQ] ) > 0
Begin
    Select Top 1 @sol =[studentAnswer]  From [dbo].[MCQ]
	Select Top 1  @Id = [mcqQId] From [dbo].[MCQ]
	set @correctAnswer = (select [correctAns] from [dbo].[mcqQusetion] where [questionId]=@Id)
	if @sol=@correctAnswer
	begin
	set @grade=@grade+1;
	end
	Delete [dbo].[MCQ] Where  [mcqQId]= @Id;
End
return @grade
end

--------------------------------CorrectT&FQuestion----------------------------------------------------
create PROCEDURE CorrectTFQuestion
As
begin
declare @grade int 
set @grade=0
declare @sol nvarchar(200)
Declare @Id int
Declare @correctAnswer nvarchar(200)

While (Select Count(*) From [dbo].[TF] ) > 0
Begin
    Select Top 1 @sol =[studentAnswer]  From [dbo].[TF]
	Select Top 1  @Id = [tfQId] From [dbo].[TF]
	set @correctAnswer = (select [correctAns] from [dbo].[T&FQuestion] where [questionId]=@Id)
	if @sol=@correctAnswer
	begin
	set @grade=@grade+1;
	print @grade
	end
	Delete [dbo].[TF] Where  [tfQId]= @Id;
End
return @grade
end

------------------------------main----------------------------------
insert into [T&FQuestion] values ('Iam play tennis every Sunday morning','T','F','T');
insert into [T&FQuestion] values ('Jun-Sik cleans his teeth before breakfast every morning','T','F','T');
insert into [T&FQuestion] values ('Iam play tennis every Sunday morning','T','F','T');
insert into [T&FQuestion] values ('Jun-Sik cleans his teeth before breakfast every morning','T','F','T');
insert into [T&FQuestion] values ('Iam play tennis every Sunday morning','T','F','T');
insert into [T&FQuestion] values ('Jun-Sik cleans his teeth before breakfast every morning','T','F','T');
insert into [T&FQuestion] values ('Iam play tennis every Sunday morning','T','F','T');
insert into [T&FQuestion] values ('Jun-Sik cleans his teeth before breakfast every morning','T','F','T');
EXECUTE getRandomMcq
EXECUTE getRandomTf
EXECUTE getRandomEssay
generateExam
exec AnswerMcqQuestion 'am play',1
exec AnswerMcqQuestion 'tried',2
exec AnswerTFQuestion 'T',2
exec AnswerTFQuestion 'T',3
exec AnswerTFQuestion 'T',6
exec AnswerTFQuestion 'F',8
exec AnswerTFQuestion 'F',10


declare @MCQres int 
exec @MCQres = CorrectMcqQuestion
select @MCQres

declare @TFres int
exec @TFres = CorrectTFQuestion
select @TFres
 ----------------------------------------------------------------------
create procedure checkAnswers @correctAnswer text , @answer text
as 
begin
if @correctAnswer LIKE @answer
	return 1;
	else
	return 0;
end



alter procedure correctEssayQ
As
begin
declare @grade int 
set @grade=0
declare @res int 
set @res=0
declare @sol nvarchar(200)
Declare @Id int
Declare @correctAnswer nvarchar(200)

While (Select Count(*) From [dbo].[ESSAY] ) > 0
Begin
    Select Top 1 @sol =[studentAnswer]  From [dbo].[ESSAY]
	Select Top 1  @Id =[essayId] From [dbo].[ESSAY]
	set @correctAnswer = (select [correctAns] from [dbo].[EssayQuestion] where [questionId]=@Id)
	exec @res =checkAnswers @correctAnswer , @sol
	set @grade=@grade+@res;
	Delete  [dbo].[ESSAY] Where [essayId] = @Id;
End
return @grade
end

insert into [dbo].[EssayQuestion] values ('Jun-Sik cleans his teeth before breakfast morning' , 'shimaa adel gaber');
insert into [dbo].[EssayQuestion] values ('Jun-Sik cleans his teeth before breakfast morning' , 'amal ahmed ibrahim');
insert into [dbo].[EssayQuestion] values ('Jun-Sik cleans his teeth before breakfast morning' , 'sohaila mo7amed dyaa');

exec AnswerEssayQuestion 'shimaa adel gaber' , 1
exec AnswerEssayQuestion 'amal ahmed ibrahim' , 2
exec AnswerEssayQuestion 'vhjhygtfrr' , 3


declare @MCQres int 
exec @MCQres = correctEssayQ
select @MCQres