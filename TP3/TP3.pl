% Author:
% Date: 4/17/2013
/*
    La grammaire compl�te permettant d�analyser les questions:
phrase -> <groupe_nominal> <groupe_verbal>
groupe_nominal-> <determinant> <nom>
groupe_nominal-> <pronom_interrogatif>
groupe_nominal-> <determinant> <nom> <determinant> <nom>
nom-> nomCommun
nom-> nomPropre
groupe_verbal-> <verbe> <groupe_nominal>
pronom_interrogatif -> Qui |
determinant -> le | de | des | les | un
verbe -> est | mange-t-il | aime-t-il | aime-t-elle | poss�de-t-il
nomCommun -> p�re | croquettes | chiens  | chats | chat
nomPropre -> Felix | Pierre| Anne | Nicolas

p( SEM ) --> gn(AGNT), gv(ACT, OBJ), {AGNT \= OBJ, SEM =..[ACT,AGNT, OBJ]}.
gn( AGNT ) --> art, nc(AGNT).
gv( ACT,OBJ ) --> v(ACT), gn(OBJ).
art --> [le].
art --> [un].
nc( chien ) --> [chien].
nc( homme ) --> [homme].                       #
v( mordre ) --> [mord].

qui est le pere de nicolas
 */
 
 
 %//////////////// BASE DE CONNAISSANCES ////////////////////
 
 pere(paul,nicolas).
 frere(nicolas, pierre).
 frere(nicolas, anne).
 frere(X,Y):- frere(Y,X).
 frere(X,Y):- frere(X,Z), frere(Z,Y).
 est(garfield, chat).
 est(felix, chat).
 possede(anne, garfield).
 aime(anne, chats).
 aime(anne, chiens).
 not(aime(pierre,chien)).
 mange(X, croquettes) :- est(X, chat).
 mange(X, pate):- est(X, chat).
 
 
 
 %/////////////GRAMMAIRE DES QUESTIONS /////////////////////
repondre(Fait) --> groupe_nominal(X), groupe_verbal(Y,Z), {Fait=..[Y,X,Z]}.
groupe_nominal(X)--> determinant, nom(X).
groupe_nominal(X)--> nom(X).
groupe_nominal(X) --> pronom_interrogatif(X).
groupe_nominal(Y,Z) --> determinant, lien(Y), determinant, nom(Z).
groupe_verbal(Y,Z) --> verbe, groupe_nominal(Y,Z). %changement de X par Y et Y par Z pour compr�hension
groupe_verbal(Y,Z) --> verbe(Y), groupe_nominal(Z).
nom(X) --> nomCommun(X).
nom(X) --> nomPropre(X).
determinant-->[un].
determinant-->[le].
determinant-->[de].
determinant-->[les].
pronom_interrogatif(X)-->[qui].   %la r�ponse �crit artificiellement ici
lien(frere)-->[frere].
lien(pere)-->[pere].
nomPropre(nicolas) --> [nicolas].
nomPropre(felix) --> [felix].
nomPropre(pierre) --> [pierre].
nomPropre(anne) --> [anne].
nomCommun(pate) --> [pate].
nomCommun(croquettes) --> [croquettes].
nomCommun(chiens) --> [chiens].
nomCommun(chats) --> [chats].
nomCommun(chat) --> [chat].
verbe --> [est].
verbe(mange) --> [mangetil].
verbe(aime) --> [aimetil].
verbe(aime) --> [aimetelle].
verbe(possede) --> [possedetil].

%//////////////VALIDATION///////////////////////////////////

valide(E):- repondre(S,E,[]), verifie(S).
verifie(pere(X,Z)):- pere(X,Z).
verifie(frere(X,Z)):- frere(X,Z).
verifie(mange(X,Z)):- mange(X,Z).
verifie(aime(X,Z)):- aime(X,Z).
verifie(possede(X,Z)):- possede(X,Z).

%//////////////GRAMMAIRE DES REPONSES //////////////////////
% Methode 1  :
ecrire(S,Reponse):-  {S=..[Y,X,Z]},{Reponse=[GN,GV]}.

  /* Methode 2  :
ecrire(Phrase) --> <groupe_nominal2(GN)> <groupe_verbal2(GV)>, {Phrase=[GN,GV]}.
groupe_nominal2(DET,NOM) --> <determinant2(DET)> <nom2(NOM)>.
groupe_nominal2(DET,NOM,DET2,NOM2) --> determinant3(DET), lien2(NOM), determinant4(DET2), nom2(NOM2).
groupe_verbal2(Y,Z) --> verbe2, groupe_nominal2(Y,Z). %changement de X par Y et Y par Z pour compr�hension
groupe_verbal2(Y,Z) --> verbe2(Y), groupe_nominal2(Z).
nom2(X) --> nomCommun2(X).
nom2(X) --> nomPropre2(X).
determinant2(un)-->[un].
determinant2(le)-->[le].
determinant2(de)-->[de].
determinant2(les)-->[les].
determinant2(des)-->[des].
determinant3(le)
determinant4(de)
lien2(frere)-->[frere].
lien2(pere)-->[pere].
nomPropre2(nicolas) --> [nicolas].
nomPropre2(felix) --> [felix].
nomPropre2(pierre) --> [pierre].
nomPropre2(anne) --> [anne].
nomCommun2(pate) --> [pate].
nomCommun2(croquettes) --> [croquettes].
nomCommun2(chiens) --> [chiens].
nomCommun2(chats) --> [chats].
nomCommun2(chat) --> [chat].
verbe2 --> [est].
verbe2(mange) --> [mange].
verbe2(aime) --> [aime].
verbe2(aime) --> [aime].
verbe2(possede) --> [poss�de].
 */
%//////////////LANCER INTERFACE//////////////////

lancer :-
    lire(Chaine,Phrase),
    valide(Phrase),
    lancer
    .

lancer :-
    write('Erreur : phrase non comprise'),
    nl,
    lancer
    .

%Fonction qui exprime une liste en une phrase.
dire([X|R]) :- write(X), write(' '), dire(R).
dire([]).

% Le pr�dicat lire/2 lit une cha�ne de caract�res Chaine entre apostrophes
% et termin�e par un point.
% Resultat correspond � la liste des mots contenus dans la phrase.
% Les signes de ponctuation ne sont pas g�r�s.
lire(Chaine,Resultat):- 
    write('Entrer la phrase (exit pour quitter) '),nl, 
    read(Chaine),
    Chaine \= 'exit',
    name(Chaine, Temp), 
    chaine_liste(Temp, Resultat),
    !.

lire(Chaine, Resultat) :-
    abort.
                       
% Pr�dicat de transformation de cha�ne en liste
chaine_liste([],[]).
chaine_liste(Liste,[Mot|Reste]):- separer(Liste,32,A,B), name(Mot,A),
chaine_liste(B,Reste).

% S�pare une liste par rapport � un �l�ment
separer([],X,[],[]):-!.
separer([X|R],X,[],R):-!.
separer([A|R],X,[A|Av],Ap):- X\==A, !, separer(R,X,Av,Ap).
