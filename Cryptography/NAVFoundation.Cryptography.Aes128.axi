function NAVconstants(byref integer encS[], byref integer decS[], long_integer encMix[][], long_integer decMix[][]) {  // for lack of array literals  :^(
	integer i, x, x2, x4, x8, xInv, s, d[255], t[255];
	long_integer tEnc, tDec;
	
	// double and triple in Galois Field
	for (i = 0 to 255) {
		d[i] = i<<1 ^ (i>>7)*283;
		t[d[i]^i]=i;
	}
	   
	x = 0;
	xInv = 0;
	while ( !encS[x]) {
		// Compute sbox
	   	s = xInv ^ xInv<<1 ^ xInv<<2 ^ xInv<<3 ^ xInv<<4;
	    s = s >> 8 ^ s&255 ^ 99;
	    encS[x] = s;
	    decS[s] = x;
	    
	    // Compute Mix -- includes sub-btye, shift-row, and mix columns steps
	    x2 = d[x];
	    x4 = d[x2];
	    x8 = d[x4];
	    tDec = x8*0x1010101 ^ x4*0x10001 ^ x2*0x101 ^ x*0x1010100;
	    tEnc = d[s]*0x101 ^ s*0x1010100;
	     
	    for (i = 0 to 3) {
	    	tEnc = tEnc << 24 ^ tEnc >> 8;
	     	encMix[i][x] = tEnc;
	      	tDec = tDec << 24 ^ tDec >> 8;
	      	decMix[i][s] = tDec;
	    }
	    
	    if(x2=0)
	    	x = x ^ 1;
	    else
	      	x = x ^ x2;
	   	
	   	xInv = t[xInv];
	    if(xInv=0)
	    	xInv=1;
	}
} 

function NAVkeySchedule(byref integer encS[], long_integer decMix[][], byref long_integer encKey[], byref long_integer decKey[], byref integer keyGood){
  	integer i, j;
	long_integer tmp, rcon;
  	rcon = 1;
  	// schedule encryption keys
  	for (i = 4 to 43) {
    	tmp = encKey[i-1];
    	if (!(i&3)) {
      		tmp = encS[tmp>>24]<<24 ^ encS[tmp>>16&255]<<16 ^ encS[tmp>>8&255]<<8 ^ encS[tmp&255];
      		tmp = tmp<<8 ^ tmp>>24 ^ rcon<<24;
      		rcon = rcon<<1 ^ (rcon>>7)*283;
      	}
      	
    	encKey[i] = encKey[i-4] ^ tmp;
    }
  
  	// schedule decryption keys
  	decKey[0]=encKey[40];
  	decKey[1]=encKey[43];
  	decKey[2]=encKey[42];
  	decKey[3]=encKey[41];
  	decKey[40]=encKey[0];
  	decKey[41]=encKey[3];
  	decKey[42]=encKey[2];
  	decKey[43]=encKey[1];
  	for (j = 4 to 39){
    	i=44-j;
    	if(j&3)
      		tmp = encKey[i];
    	else
      		tmp = encKey[i - 4];
      		
    	decKey[j] = decMix[0][encS[tmp>>24]] ^ decMix[1][encS[tmp>>16 & 255]] ^ decMix[2][encS[tmp>>8 & 255]] ^ decMix[3][encS[tmp & 255]];
    }
  	
  	keyGood=1;
}

function NAVSetKey(string sKey, byref long_integer encKey[], byref integer keyGood) {
	string tmp1[16];
	integer i,l;
	keyGood=0;
	 
	tmp1=sKey;
	l=len(tmp1);
	while(l<16){
		setString("\x00",l+1,tmp1);
		l=len(tmp1);
	}
	 
	for(i=0 to 3){
		encKey[i]=byte(tmp1,i*4+1)<<24 | byte(tmp1,i*4+2)<<16 | byte(tmp1,i*4+3)<<8 | byte(tmp1,i*4+4);
	}
	
	//keySchedule();	
}

function NAVcipher(byref long_integer key[], long_integer mix[][], byref integer sbox[], byref long_integer block[]){
	long_integer a,b,c,d,e,f,g;
  	integer i,keyOffset;
  
  	// initial round
  	a = block[0] ^ key[0];
  	b = block[1] ^ key[1];
  	c = block[2] ^ key[2];
  	d = block[3] ^ key[3];
  	keyOffset = 4;
  
  	// inner rounds
  	for (i = 1 to 9) {
    	e = mix[0][a>>24] ^ mix[1][b>>16 & 255] ^ mix[2][c>>8 & 255] ^ mix[3][d & 255] ^ key[keyOffset];
    	f = mix[0][b>>24] ^ mix[1][c>>16 & 255] ^ mix[2][d>>8 & 255] ^ mix[3][a & 255] ^ key[keyOffset + 1];
    	g = mix[0][c>>24] ^ mix[1][d>>16 & 255] ^ mix[2][a>>8 & 255] ^ mix[3][b & 255] ^ key[keyOffset + 2];
    	d = mix[0][d>>24] ^ mix[1][a>>16 & 255] ^ mix[2][b>>8 & 255] ^ mix[3][c & 255] ^ key[keyOffset + 3];
    	keyOffset = keyOffset + 4;
    	a=e; b=f; c=g;
    }
  
  	// final rounds
  	for (i = 0 to 3) {
    	block[i] = sbox[a>>24]<<24 ^ sbox[b>>16 & 255]<<16 ^ sbox[c>>8 & 255]<<8 ^ sbox[d & 255] ^ key[keyOffset];
    	keyOffset=keyOffset+1;
    	e=a; a=b; b=c; c=d; d=e;
    }
}

string_function NAVencrypt(string s, byref long_integer encKey[], long_integer encMix[][], byref integer encS[]){
  	integer i,j;
  	string a[4],c[16];
  	long_integer block[3];
  	a="1234"; // filler

  	for(i=0 to 3){
    	j=i*4+1;
    	block[i]=byte(s,j)<<24 | byte(s,j+1)<<16 | byte(s,j+2)<<8 | byte(s,j+3);
    }

  	NAVcipher(encKey, encMix, encS, block);

  	for(i=0 to 3){
    	setByte(a,1,low(block[i]>>24));
    	setByte(a,2,low(block[i]>>16));
    	setByte(a,3,low(block[i]>>8));
    	setByte(a,4,low(block[i]));
//    	a=chr(low(block[i]>>24))+chr(low(block[i]>>16))+chr(low(block[i]>>8))+chr(low(block[i])); // slower
    	setString(a,i*4+1,c);
    }
  	
  	return(c);
}

string_function NAVdecrypt(string s, byref long_integer decKey[], long_integer decMix[][], byref integer decS[]){
	integer i,j;
  	string a[4],p[16];
  	long_integer block[3];
  	a="1234"; //filler
  	for(i=0 to 3){
    	j=i*4+1;
    	block[3&-i]=byte(s,j)<<24 | byte(s,j+1)<<16 | byte(s,j+2)<<8 | byte(s,j+3);
    }

  	NAVcipher(decKey, decMix, decS, block);

  	for(i=0 to 3){
    	j=3&-i;
    	setByte(a,1,low(block[j]>>24));
    	setByte(a,2,low(block[j]>>16));
    	setByte(a,3,low(block[j]>>8));
    	setByte(a,4,low(block[j]));
//    	a=chr(low(block[j]>>24))+chr(low(block[j]>>16))+chr(low(block[j]>>8))+chr(low(block[j]));
    	setString(a,i*4+1,p);
    }
  	
  	return(p);
}

string_function NAV_AES128_Encrypt(string sStringToEncrypt, string sKey) {
	string in[255],out[255],tmp1[16],tmp2[16];
  	integer i,l, keyGood, encS[255], decS[255];
  	long_integer b[16], encKey[43], decKey[43], encMix[3][255], decMix[3][255];
  	
  	//keyGood = 0;
  	NAVconstants(encS, decS, encMix, decMix);
  	encKey[0]=0;
 	encKey[1]=0; 
  	encKey[2]=0; 
  	encKey[3]=0;
  	NAVSetKey(sKey, encKey, keyGood);
  	NAVkeySchedule(encS, decMix, encKey, decKey, keyGood);
  	  	
  	in=sStringToEncrypt;
	//  in=to_encrypt+"\x80";
  	while(keyGood=0){delay(1);}  
  	l=len(in);
  	i=16-l&0xf;
  	while(l&0xf){
    	setString(chr(i),l+1,in);
    	l=len(in);
    }
  
  	i=1;
  	while(i<l){
    	tmp1=mid(in,i,16);
    	tmp2=NAVencrypt(tmp1, encKey, encMix, encS);
    	setString(tmp2,i,out);
    	i=i+16;
//    	processLogic();
    }
  	
  	return(out);
}

string_function NAV_AES128_Decrypt(string sStringToDecrypt, string sKey) {
	string in[255],out[255],tmp1[16],tmp2[16];
  	integer i,l, keyGood, encS[255], decS[255];
  	long_integer b[16], encKey[43], decKey[43], encMix[3][255], decMix[3][255];
  	
  	//keyGood = 0;
  	NAVconstants(encS, decS, encMix, decMix);
  	encKey[0]=0;
 	encKey[1]=0; 
  	encKey[2]=0; 
  	encKey[3]=0;
  	NAVSetKey(sKey, encKey, keyGood);
  	NAVkeySchedule(encS, decMix, encKey, decKey, keyGood);
  	  	
  	in=sStringToDecrypt;
	while(keyGood=0){delay(1);}  
  	i=1;l=len(in);
  	while(i<l){
    	tmp1=mid(in,i,16);
    	tmp2=NAVdecrypt(tmp1, decKey, decMix, decS);
    	setString(tmp2,i,out);
    	i=i+16;
//    	processLogic();
    }
    
  	i=byte(out,len(out)); 
  	return(left(out,len(out)-i));
}