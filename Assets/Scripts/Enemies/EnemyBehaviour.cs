using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;


[RequireComponent(typeof(EnemyMovement))]
[RequireComponent(typeof(EnemyShoot))]

public class EnemyBehaviour : FiniteStateMachine
{
    public enum State { INITIAL, WANDER, ATTACK, STUN };

    public State m_currentState = State.INITIAL;
    
    private GameObject m_player;

    [Header("Attributes of the FSM")]
    [SerializeField]
    private float m_playerInRange;

    [SerializeField]
    private float m_playerOutOfRange;

    private bool m_mushroomImpact;

    private EnemyMovement m_enemyMovement;
    private EnemyShoot m_enemyShoot;

    public void SetMushroomHit(bool value)
    {
        m_mushroomImpact = value;
    }

    public bool GetMushroomHit()
    {
        return m_mushroomImpact;
    }

    private void Start()
    {
        m_enemyMovement = GetComponent<EnemyMovement>();
        m_enemyShoot = GetComponent<EnemyShoot>();

        m_enemyMovement.enabled = false;
    }

    public override void Exit()
    {
        m_enemyMovement.enabled = false;
        base.Exit();
    }

    public override void ReEnter()
    {
        m_currentState = State.INITIAL;
        base.ReEnter();
    }

    private void Update()
    {
        
        switch(m_currentState)
        {

            case State.INITIAL:
                ChangeState(State.WANDER);
                break;

            case State.WANDER:

                // stun mushroom 

                if (m_mushroomImpact)
                {
                    ChangeState(State.STUN);
                    break;
                }

                // find player if in range

                m_player = UtilsGyromitra.FindInstanceWithinRadius(gameObject, UtilsGyromitra.SearchForTag("Player"), m_playerInRange);

                if (UtilsGyromitra.DistanceToTarget(this.gameObject,m_player) <= m_playerInRange)
                {
                    ChangeState(State.ATTACK);
                    break;
                }
                
                break;

            case State.ATTACK:

                // stun mushroom 

                if (m_mushroomImpact)
                {
                    ChangeState(State.STUN);
                    break;
                }

                // find player if out of range

                m_player = UtilsGyromitra.FindInstanceWithinRadius(gameObject, UtilsGyromitra.SearchForTag("Player"), m_playerInRange);

                if (UtilsGyromitra.DistanceToTarget(this.gameObject, m_player) >= m_playerOutOfRange)
                {
                    ChangeState(State.WANDER);
                    break;
                }
                break;

            case State.STUN:


                m_player = UtilsGyromitra.FindInstanceWithinRadius(gameObject, UtilsGyromitra.SearchForTag("Player"), m_playerInRange);

                // find player if in range

                if (UtilsGyromitra.DistanceToTarget(this.gameObject, m_player) <= m_playerInRange)
                {
                    ChangeState(State.ATTACK);
                    break;
                }

                // find player if out of range

                if (UtilsGyromitra.DistanceToTarget(this.gameObject, m_player) >= m_playerOutOfRange)
                {
                    ChangeState(State.WANDER);
                    break;
                }

                break;
        }
    }

    private void ChangeState(State l_newState)
    {
        // exit logic
        switch (m_currentState)
        {
            case State.WANDER:
                m_enemyMovement.enabled = false;
                break;

            case State.ATTACK:
                m_enemyShoot.enabled = false;                
                break;

            case State.STUN:
                break;

        }

        // enter logic
        switch (m_currentState)
        {

            case State.WANDER:
                break;  

            case State.ATTACK:
                m_enemyShoot.setPlayer(m_player);
                break;
                    
            case State.STUN:
                break;

        }

        m_currentState = l_newState;

    }

}
