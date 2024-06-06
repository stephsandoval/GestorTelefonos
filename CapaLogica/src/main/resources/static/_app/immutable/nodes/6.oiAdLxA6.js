import{s as ae,n as X,b as se}from"../chunks/scheduler.BvLojk_z.js";import{S as le,i as oe,e as f,s as k,b as O,c as u,d as b,m as Y,h as F,f as P,g as d,n as E,j as te,k as t,r as ne,l as j}from"../chunks/index.FRP66Aq7.js";import{e as Z}from"../chunks/each.D6YF6ztN.js";import{p as re}from"../chunks/stores.CXUeqMq_.js";function x(r,e,n){const c=r.slice();return c[5]=e[n],c}function ee(r){let e,n,c=r[5].fecha+"",C,v,p,H=r[5].numeroOrigen+"",T,m,h,D=r[5].numeroDestino+"",S,q,_,l=r[5].condicion+"",o,i,a,L=r[5].horaInicio+"",I,N,M,V=r[5].horaFin+"",A,J,R,w=r[5].duracion+"",B,$;return{c(){e=f("tr"),n=f("td"),C=O(c),v=k(),p=f("td"),T=O(H),m=k(),h=f("td"),S=O(D),q=k(),_=f("td"),o=O(l),i=k(),a=f("td"),I=O(L),N=k(),M=f("td"),A=O(V),J=k(),R=f("td"),B=O(w),$=k(),this.h()},l(g){e=u(g,"TR",{});var s=b(e);n=u(s,"TD",{class:!0});var y=b(n);C=P(y,c),y.forEach(d),v=F(s),p=u(s,"TD",{class:!0});var z=b(p);T=P(z,H),z.forEach(d),m=F(s),h=u(s,"TD",{class:!0});var G=b(h);S=P(G,D),G.forEach(d),q=F(s),_=u(s,"TD",{class:!0});var K=b(_);o=P(K,l),K.forEach(d),i=F(s),a=u(s,"TD",{class:!0});var Q=b(a);I=P(Q,L),Q.forEach(d),N=F(s),M=u(s,"TD",{class:!0});var U=b(M);A=P(U,V),U.forEach(d),J=F(s),R=u(s,"TD",{class:!0});var W=b(R);B=P(W,w),W.forEach(d),$=F(s),s.forEach(d),this.h()},h(){E(n,"class","svelte-p3h6no"),E(p,"class","svelte-p3h6no"),E(h,"class","svelte-p3h6no"),E(_,"class","svelte-p3h6no"),E(a,"class","svelte-p3h6no"),E(M,"class","svelte-p3h6no"),E(R,"class","svelte-p3h6no")},m(g,s){te(g,e,s),t(e,n),t(n,C),t(e,v),t(e,p),t(p,T),t(e,m),t(e,h),t(h,S),t(e,q),t(e,_),t(_,o),t(e,i),t(e,a),t(a,I),t(e,N),t(e,M),t(M,A),t(e,J),t(e,R),t(R,B),t(e,$)},p(g,s){s&1&&c!==(c=g[5].fecha+"")&&j(C,c),s&1&&H!==(H=g[5].numeroOrigen+"")&&j(T,H),s&1&&D!==(D=g[5].numeroDestino+"")&&j(S,D),s&1&&l!==(l=g[5].condicion+"")&&j(o,l),s&1&&L!==(L=g[5].horaInicio+"")&&j(I,L),s&1&&V!==(V=g[5].horaFin+"")&&j(A,V),s&1&&w!==(w=g[5].duracion+"")&&j(B,w)},d(g){g&&d(e)}}}function he(r){let e,n,c="Facturador de servicios telefónicos",C,v,p,H,T,m,h,D,S='<th class="svelte-p3h6no">Fecha</th> <th class="svelte-p3h6no">Número que inicio la llamada</th> <th class="svelte-p3h6no">Número que recibe la llamada</th> <th class="svelte-p3h6no">Tipo de llamada</th> <th class="svelte-p3h6no">Hora de inicio</th> <th class="svelte-p3h6no">Hora de fin</th> <th class="svelte-p3h6no">Cantidad minutos</th>',q,_=Z(r[0]),l=[];for(let o=0;o<_.length;o+=1)l[o]=ee(x(r,_,o));return{c(){e=f("div"),n=f("h1"),n.textContent=c,C=k(),v=f("h2"),p=O("Llamadas de la empresa: "),H=O(r[1]),T=k(),m=f("div"),h=f("table"),D=f("tr"),D.innerHTML=S,q=k();for(let o=0;o<l.length;o+=1)l[o].c();this.h()},l(o){e=u(o,"DIV",{class:!0});var i=b(e);n=u(i,"H1",{class:!0,"data-svelte-h":!0}),Y(n)!=="svelte-fhugsi"&&(n.textContent=c),C=F(i),v=u(i,"H2",{class:!0});var a=b(v);p=P(a,"Llamadas de la empresa: "),H=P(a,r[1]),a.forEach(d),T=F(i),m=u(i,"DIV",{class:!0,id:!0});var L=b(m);h=u(L,"TABLE",{class:!0});var I=b(h);D=u(I,"TR",{"data-svelte-h":!0}),Y(D)!=="svelte-d69xv7"&&(D.innerHTML=S),q=F(I);for(let N=0;N<l.length;N+=1)l[N].l(I);I.forEach(d),L.forEach(d),i.forEach(d),this.h()},h(){E(n,"class","svelte-p3h6no"),E(v,"class","svelte-p3h6no"),E(h,"class","svelte-p3h6no"),E(m,"class","lista"),E(m,"id","lista"),E(e,"class","main")},m(o,i){te(o,e,i),t(e,n),t(e,C),t(e,v),t(v,p),t(v,H),t(e,T),t(e,m),t(m,h),t(h,D),t(h,q);for(let a=0;a<l.length;a+=1)l[a]&&l[a].m(h,null)},p(o,[i]){if(i&1){_=Z(o[0]);let a;for(a=0;a<_.length;a+=1){const L=x(o,_,a);l[a]?l[a].p(L,i):(l[a]=ee(L),l[a].c(),l[a].m(h,null))}for(;a<l.length;a+=1)l[a].d(1);l.length=_.length}},i:X,o:X,d(o){o&&d(e),ne(l,o)}}}function ce(r,e,n){let c;se(r,re,T=>n(2,c=T));let C=c.url.searchParams.get("empresa"),v=c.url.searchParams.get("fechaCierre"),p=[];return(async()=>{await fetch("http://localhost:8080/api/getListaLlamadasEmpresa",{method:"POST",body:JSON.stringify({empresa:C,fechaCierre:v})}).then(T=>{T.json().then(m=>{n(0,p=m)})})})(),[p,C]}class ve extends le{constructor(e){super(),oe(this,e,ce,he,ae,{})}}export{ve as component};
