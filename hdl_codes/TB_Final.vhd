library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity TB_final is 
end entity TB_final;

architecture Behavior of TB_final is 
 
--module adv_adc (clock, reset, go, sclk, cs_n, din, dout, done, chan, reading0, reading1, 
--						reading2, reading3, reading4, reading5, reading6, reading7);
						
	component bouton is
port (
	CLOCK_50 : in std_logic;
	LEDR 		: out std_logic_vector(9 downto 0);
	SW 		: in std_logic_vector(9 downto 0);
	KEY 		: in std_logic_vector(3 downto 0);
	ADC_DOUT : in std_logic;
	ADC_SCLK : out std_logic;
	ADC_CS_N : out std_logic;
	ADC_DIN	: out std_logic
);
end component;
	component adv_adc is
port (
		GO 		 : in std_logic;
		CLOCK     : in  std_logic;                     			--         clk.clk
		RESET     : in  std_logic;
		CHAN      : in std_logic_vector(2 downto 0);        --    CHAN
		DOUT 		 : in std_logic;
		SCLK  	 : out std_logic;                            -- adc_signals.SCLK
		CS_N  	 : out std_logic;									  --            .CS_N
		DIN		 : out std_logic
);
end component adv_adc;

   signal sClOCK_50     : std_logic;                            --       reset.reset
   signal sLEDR     		: std_logic_vector(9 downto 0):= "0000000000";
   signal sSW     		: std_logic_vector(9 downto 0):= "0000000000";                    			--         clk.clk
   signal sKEY  			: std_logic_vector(3 downto 0):= "0000";                     		   --            .SDAT
   signal sADC_DOUT  	: std_logic;                            -- 
   signal sADC_SCLK  	: std_logic;                      		   --            .CS_N
   signal sADC_CS_N	   : std_logic;                            --            
	signal sADC_DIN	   : std_logic; 
	
--	signal sGO 		 		: std_logic;
--	signal sCLOCK     		: std_logic;                     			--         clk.clk
--	signal sRESET     		: std_logic;
--	signal sCHAN      		: std_logic_vector(2 downto 0);        --    CHAN
--	signal sDOUT 		 	: std_logic;
--	signal sSCLK  	 		: std_logic;                            -- adc_signals.SCLK
--	signal sCS_N  	 		: std_logic;									  --            .CS_N
--	signal sDIN		 		: std_logic;	
constant clk_period : time := 10 ns;

begin
 
 	bouton_TB_signal : component bouton 
		port map (
			CLOCK_50   =>  sCLOCK_50,
			LEDR		  =>  sLEDR,
			SW    	  =>  sSW,
			KEY 		  =>  sKEY,
			ADC_DOUT   =>  sADC_DOUT,
			ADC_SCLK   =>  sADC_SCLK,
			ADC_CS_N   =>  sADC_CS_N,
			ADC_DIN 	  =>  sADC_DIN
		);
-- 	adv_adc_signal : component adv_adc
--		port map (
--			GO 					=> sGO,
--			CLOCK 				=> sCLOCK,
--			RESET					=> sRESET,
--			CHAN  				=> sCHAN,
--			DOUT 					=> sDOUT,
--			SCLK 					=> sSCLK,
--			CS_N 					=> sCS_N,
--			DIN 					=> sDIN
--		); 
		
	clk_process :process
begin
	sCLOCK_50 <= '1';
	wait for clk_period/2;
	sCLOCK_50 <= '0';
	wait for clk_period/2;
end process;

bouton_process : process
begin
		wait until sADC_SCLK = '1';
		wait until sADC_SCLK = '1';
		wait until sADC_SCLK = '1';
		wait until sADC_SCLK = '1';
	sKEY(0) <= '1';
		wait for clk_period*20;
	sKEY(0) <= '0';
	wait;
end process;

	go_process :process
	begin
		--sSW(0) <= '0';
		if (sSW(9 downto 7)= "111") then
			sSW(9 downto 7)<= "000";
		else
			sSW(9 downto 7) <= std_logic_vector ( unsigned(sSW(9 downto 7)) + 1);
		end if;
		sSW(0) <='0';
		wait until sADC_SCLK = '1';
		wait until sADC_SCLK = '1';
		wait until sADC_SCLK = '1';
		sSW(0) <= '1';
		wait until sADC_SCLK = '1';
		wait until sADC_SCLK = '1';
		wait until sADC_SCLK = '1';
end process;


	trans_process :process
	begin
		wait until sADC_CS_N = '0';
		sADC_DOUT <='0';
		wait until sADC_SCLK = '0';	-- Attention ! Il faut utiliser sCLK (clock du ADC)  A[2]
		sADC_DOUT <= sSW(9);
		wait until sADC_SCLK = '0';
		sADC_DOUT <= sSW(8);
		wait until sADC_SCLK = '0';
		sADC_DOUT <= sSW(7);
		wait until sADC_SCLK = '0';
		wait until sADC_SCLK = '0';
		wait until sADC_SCLK = '0';
		sADC_DOUT <='1';
		wait until sADC_SCLK = '0';
		sADC_DOUT <='0';
		wait until sADC_SCLK = '0';
		wait until sADC_SCLK = '0';
		sADC_DOUT <='1';
		wait until sADC_SCLK = '0';
		wait until sADC_SCLK = '0';
		sADC_DOUT <='0';
		wait until sADC_SCLK = '0';
	end process;

	
end architecture Behavior;