library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity adv_adc_TB is 
end entity adv_adc_TB;

architecture Behavior of adv_adc_TB is 
 
--module adv_adc (clock, reset, go, sclk, cs_n, din, dout, done, chan, reading0, reading1, 
--						reading2, reading3, reading4, reading5, reading6, reading7);
						
	component adv_adc is
		port (
			CLOCK     : in  std_logic;                     			--         clk.clk
			RESET     : in  std_logic;                            --       reset.reset
			GO     	 : in  std_logic;
			SCLK  : out std_logic;                            -- adc_signals.SCLK
			CS_N  : out std_logic;									  --            .CS_N
			DIN	: out std_logic;                            --            .SADDR
			DOUT  	 : in  std_logic;                     		   --            .SDAT
			DONE	: out std_logic;                            --            .DONE
			CHAN       : in std_logic_vector(2 downto 0);        --    CHAN	
			Reading0       : out std_logic_vector(11 downto 0);        --    readings.CH0
			Reading1       : out std_logic_vector(11 downto 0);        --            .CH1
			Reading2  		: out std_logic_vector(11 downto 0);        --            .CH2
			Reading3       : out std_logic_vector(11 downto 0);        --            .CH3
			Reading4       : out std_logic_vector(11 downto 0);        --            .CH4
			Reading5       : out std_logic_vector(11 downto 0);        --            .CH5
			Reading6       : out std_logic_vector(11 downto 0);        --            .CH6
			Reading7       : out std_logic_vector(11 downto 0)
		);
		

		
	end component;

   signal sRESET     : std_logic;                            --       reset.reset
   signal sGO     	: std_logic;
   signal sCLOCK     : std_logic;                     			--         clk.clk
   signal sDOUT  		: std_logic;                     		   --            .SDAT

   signal sSCLK  : std_logic;                            -- 
   signal sCS_N  : std_logic;                      		   --            .CS_N
   signal sDIN	  : std_logic;                            --            
	signal sDONE	  : std_logic;  		
   signal sReading0       : std_logic_vector(11 downto 0);        --
   signal sReading1       : std_logic_vector(11 downto 0);        --           
   signal sReading2       : std_logic_vector(11 downto 0);        --           
   signal sReading3       : std_logic_vector(11 downto 0);        --           
   signal sReading4       : std_logic_vector(11 downto 0);        --            
   signal sReading5       : std_logic_vector(11 downto 0);        --            
	signal sReading6       : std_logic_vector(11 downto 0);        --            
	signal sReading7       : std_logic_vector(11 downto 0);
	signal sCH_CONF		  : std_logic_vector(2 downto 0) := "111";

	constant clk_period : time := 10 ns;
begin
 
 	de1_soc_adc_mega_0 : component adv_adc 
		port map (
			CLOCK     => sCLOCK,     --         clk.clk
			RESET     => sRESET,     --       reset.reset
			GO => sGO,
			SCLK  => sSCLK,  -- adc_signals.export
			CS_N  => sCS_N,  --            .export
			DIN => sDIN,  --            .export
			DOUT  => sDOUT,  --            .export
			DONE  => sDONE,  --            .export
			CHAN  => sCH_CONF,  --            .export
			Reading0       => sReading0,       --    readings.export
			Reading1       => sReading1,       --            .export
			Reading2       => sReading2,       --            .export
			Reading3       => sReading3,       --            .export
			Reading4       => sReading4,       --            .export
			Reading5       => sReading5,       --            .export
			Reading6       => sReading6,       --            .export
			Reading7       => sReading7       --            .export
		); 
		
	clk_process :process
	begin
		sCLOCK <= '1';
		wait for clk_period/2;
		sCLOCK <= '0';
		wait for clk_period/2;
	end process;
	   
	launch_process :process
	begin
		wait for clk_period;
		sRESET <= '0';
		wait for clk_period*10;
		sRESET <= '1';
		wait for clk_period;
		sRESET <= '0';
		wait;
	end process;
	
	trans_process :process
	begin
		wait until sCS_N = '0';
		sDOUT <='0';
		wait until sSCLK = '0';	-- Attention ! Il faut utiliser sCLK (clock du ADC)  A[2]
		sDOUT <= sCH_CONF(2);
		wait until sSCLK = '0';
		sDOUT <= sCH_CONF(1);
		wait until sSCLK = '0';
		sDOUT <= sCH_CONF(0);
		wait until sSCLK = '0';
		wait until sSCLK = '0';
		wait until sSCLK = '0';
		sDOUT <='1';
		wait until sSCLK = '0';
		sDOUT <='0';
		wait until sSCLK = '0';
		wait until sSCLK = '0';
		sDOUT <='1';
		wait until sSCLK = '0';
		wait until sSCLK = '0';
		sDOUT <='0';
		wait until sSCLK = '0';
	end process;
	
	go_process :process
	begin
		sGO <='1';
		wait until sCS_N = '1'; --- A <= "000" ; A <= A + "001";
		if (sCH_CONF= "111") then
			sCH_CONF<= "000";
		else
			sCH_CONF <= std_logic_vector ( unsigned(sCH_CONF) + 1);
		end if;
		sGO <='0';
		wait for clk_period*3;
	end process;

--toto : process
--begin	
--sGO <= SW(0);
--LEDR (0) <= sGO;
--sRESET <= KEY(0);
--sCLOCK <= CLOCK_50;
--sCHAN(2 downto 0) <= SW(9 downto 7);
--sDOUT <= ADC_DOUT;
--ADC_CS_N <= sCS_N;
--ADC_DIN <= sDIN;
--ADC_SCLK <= sSCLK;
--LEDR(9 downto 7) <= SW(9 downto 7);
--LEDR (1) <= sRESET;
--end process;
	
end architecture Behavior;