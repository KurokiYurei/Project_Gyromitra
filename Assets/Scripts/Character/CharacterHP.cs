using FMOD.Studio;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.Rendering.Universal;

public class CharacterHP : MonoBehaviour, IDamagable
{
    public float m_health { get; set; }

    private float m_maxHealth;
    private float m_minHealth;

    private float m_startTimeToRegen;

    [SerializeField]
    private float m_timerToRegen;

    [SerializeField]
    private float m_tickPerSecondHealth;

    private float m_healthPerSecond;

    [SerializeField]
    private UI_Manager m_ui;

    [SerializeField]
    private RagdollController m_ragdollController;

    [SerializeField]
    private GameObject m_postPro;

    private Vignette m_vignette;

    [Header("Health Shader")]
    [SerializeField]
    private Material m_quiverShader;

    private Color m_fullHealthColor;
    private Color m_damagedHealthColor;
    private Color m_crititalHealthColor;

    [Header("FMOD")]
    [SerializeField]
    private Transform m_soundEmitter;

    [SerializeField]
    private EventInstance m_eventDie;

    private float m_timer;

    //[SerializeField]
    //private EventInstance m_eventRegen;

    [SerializeField]
    private EventInstance m_eventLowHealth;

    private bool m_played;

    private void Awake()
    {
        m_eventDie = FMODUnity.RuntimeManager.CreateInstance("event:/Personatge/17 - Death sound");
        //m_eventRegen = FMODUnity.RuntimeManager.CreateInstance("event:/Personatge/15 - Curaci�");
        m_eventLowHealth = FMODUnity.RuntimeManager.CreateInstance("event:/Personatge/HearthBeat");
        m_played = false;
    }

    void Start()
    {
        m_minHealth = 0f;
        m_maxHealth = 100f;

        m_timerToRegen = 2f;
        m_startTimeToRegen = 3f;
        m_healthPerSecond = 10f;
        m_tickPerSecondHealth = 1f;

        m_timer = 1f;

        m_health = m_maxHealth;

        m_fullHealthColor = new Color(0, 255, 0, 255)*0.05f;
        m_damagedHealthColor = new Color(0, 0, 255, 255)*0.5f;
        m_crititalHealthColor = new Color(255, 0, 0, 255) * 0.5f;

        m_quiverShader.SetColor("_EmissionColor", m_fullHealthColor);
    }

    void Update()
    {

        m_timer -= Time.deltaTime;

        if (m_timer <= 0f && m_played == true)
        {
            print("canplay");
            m_timer = 1f;
            m_played = false;
        }

        if(m_postPro == null)
        {
            m_postPro = GameObject.Find("PostProcessing");
            var v = m_postPro.GetComponent<UnityEngine.Rendering.Volume>()?.profile;
            v.TryGet(out m_vignette);
        }

        m_ui.SetHealth(m_health);

        if (m_health >= 66)
        {
            m_quiverShader.SetColor("_EmissionColor", m_fullHealthColor);
        }
        else {
            if (m_health < 66 && m_health >= 33)
            {
                m_quiverShader.SetColor("_EmissionColor", m_damagedHealthColor);
            }
            else {
                m_quiverShader.SetColor("_EmissionColor", m_crititalHealthColor);}
        }

        m_timerToRegen -= Time.deltaTime;

        if(m_health <= 66f && !m_played)
        {
            print("playsound");
            UtilsGyromitra.playSound(m_eventLowHealth, m_soundEmitter);
            m_played = true;
        } else
        {
            m_played = false;
            UtilsGyromitra.stopSound(m_eventLowHealth);
        }

        if (m_timerToRegen <= 0f && m_health <= 100f)
        {
            m_tickPerSecondHealth -= Time.deltaTime;

            if (m_tickPerSecondHealth <= 0f)
            {
                Regen();
                m_tickPerSecondHealth = 1f;

            }
        }
    }

    /// <summary>
    /// Deal damage to the player
    /// </summary>
    /// <param name="damage"></param>
    public void Damage(float damage)
    {
        m_timerToRegen = m_startTimeToRegen;
        m_health -= damage;
        StartCoroutine(VignetteEffect());
        if (m_health <= m_minHealth)
        {
            transform.GetComponentInChildren<NewCameraController>().SetFollowAt(false);
            gameObject.GetComponent<PlayerInput>().enabled = false;
            StartCoroutine(waitToDie());
            UtilsGyromitra.playSound(m_eventDie, m_soundEmitter);
        }
    }

    IEnumerator waitToDie()
    {
        m_ragdollController.EnableRagdoll();
        yield return new WaitForSeconds(0.5f);
        m_ragdollController.DisableRagdoll();
        GameManagerScript.m_instance.RestartGame();
    }

    /// <summary>
    /// regen function
    /// </summary>
    public void Regen()
    {
        if(m_health >= m_maxHealth)
        {
            //UtilsGyromitra.stopSound(m_eventRegen);
            m_health = m_maxHealth;
        }
        else
        {
            //UtilsGyromitra.playSound(m_eventRegen, m_soundEmitter);
            m_health += m_healthPerSecond;
        }
    }

    /// <summary>
    /// reset hp of the player
    /// </summary>
    public void ResetHP()
    {
        m_health = m_maxHealth;
    }
    public IEnumerator VignetteEffect()
    {
        m_vignette.intensity.Override(0.35f);
        m_vignette.color.value = Color.red;
        yield return new WaitForSeconds(0.2f);
        m_vignette.intensity.Override(0.2f);
        m_vignette.color.value = Color.black;
    }
}
